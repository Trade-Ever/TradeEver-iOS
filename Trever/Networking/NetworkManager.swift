import Foundation
import Alamofire
import UIKit

// MARK: - Token Interceptor
final class TokenInterceptor: RequestInterceptor, @unchecked Sendable {
    private var isRetrying = false
    private var retryCount = 0
    private let maxRetryCount = 1
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var request = urlRequest
        
        // Google login API는 Authorization 헤더 추가하지 않음
        if !(request.url?.absoluteString.contains("/users/auth/google/login") ?? false) {
            if let authHeader = TokenManager.shared.authorizationHeader.first {
                request.setValue(authHeader.value, forHTTPHeaderField: authHeader.key)
            }
        }
        
        completion(.success(request))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        // 재시도 횟수 초과 시 무한 반복 방지
        if retryCount >= maxRetryCount {
            print("최대 재시도 횟수 초과 - 무한 반복 방지")
            completion(.doNotRetry)
            return
        }
        
        // 이미 재시도 중이면 무한 반복 방지
        if isRetrying {
            print("이미 토큰 재발급 시도 중 - 무한 반복 방지")
            completion(.doNotRetry)
            return
        }
        
        // 401 에러인 경우 토큰 재발급 시도
        if let response = request.task?.response as? HTTPURLResponse,
           response.statusCode == 401 {
            
            print("401 에러 감지 - 토큰 재발급 시도 (재시도 횟수: \(retryCount + 1)/\(maxRetryCount))")
            isRetrying = true
            retryCount += 1
            
            Task {
                let success = await NetworkManager.shared.reissueToken()
                
                await MainActor.run {
                    isRetrying = false
                    
                    if success {
                        print("토큰 재발급 성공 - 요청 재시도")
                        completion(.retry)
                    } else {
                        print("토큰 재발급 실패 - 로그아웃 처리")
                        // 재시도 횟수 리셋
                        retryCount = 0
                        Task {
                            await AuthViewModel.shared.signOut()
                        }
                        completion(.doNotRetry)
                    }
                }
            }
        } else {
            completion(.doNotRetry)
        }
    }
}

enum APIEndpoint {
    static let baseURL = "https://www.trever.store/api"
    
    case vehicles
    case manufacturers
    case carNames
    case modelNames
    case years
    case recentSearch
    case deleteRecentSearch(keyword: String)
    case vehicleSearch
    case vehicleManufacturers
    case vehicleNames(manufacturer: String)
    case vehicleModels(manufacturer: String, carName: String)
    case vehicleCheckCarNumber(carNumber: String)
    case myVehicles(currentPage: Int, pageSize: Int)
    
    var url: String {
        switch self{
        case .vehicles:
            return "\(APIEndpoint.baseURL)/vehicles"
        case .manufacturers:
            return "\(APIEndpoint.baseURL)/cars/manufacturers" // 제조사
        case .carNames:
            return "\(APIEndpoint.baseURL)/cars/carnames" // 차명
        case .modelNames:
            return "\(APIEndpoint.baseURL)/cars/modelnames" // 모델명
        case .years:
            return "\(APIEndpoint.baseURL)/cars/years" // 연식
        case .recentSearch:
            return "\(APIEndpoint.baseURL)/v1/recent-searches" // 최근 검색어 조회
        case .deleteRecentSearch(let keyword):
            return "\(APIEndpoint.baseURL)/v1/recent-searches?keyword=\(keyword)" // 최근 검색어 삭제
        case .vehicleSearch:
            return "\(APIEndpoint.baseURL)/vehicles/search" // 차량 검색
        case .vehicleManufacturers:
            return "\(APIEndpoint.baseURL)/vehicles/manufacturers" // 제조사별 차량 수 조회
        case .vehicleNames(let manufacturer):
            return "\(APIEndpoint.baseURL)/vehicles/manufacturers/\(manufacturer)/car-names" // 제조사별 차명별 차량 수 조회
        case .vehicleModels(let manufacturer, let carName):
            return "\(APIEndpoint.baseURL)/vehicles/manufacturers/\(manufacturer)/car-names/\(carName)/car-models" // 제조사별 차명별 차량 수 조회
        case .vehicleCheckCarNumber(let carNumber):
            return "\(APIEndpoint.baseURL)/vehicles/check-car-number?carNumber=\(carNumber)" // 차량 번호판 중복 검사
        case .myVehicles(let currentPage, let pageSize):
            return "\(APIEndpoint.baseURL)/vehicles/my-vehicles?page=\(currentPage)&size=\(pageSize)&sortBy=createdAt" // 내가 등록한 차량 목록
        }
    }
}

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    private let baseURL = "https://www.trever.store/api"
    //    private let baseURL = "http://54.180.107.111:8080/api"
    
    // Alamofire Session with interceptor
    private lazy var session: Session = {
        let configuration = URLSessionConfiguration.default
        let interceptor = TokenInterceptor()
        return Session(configuration: configuration, interceptor: interceptor)
    }()
    
    func searchVehicles(request: CarSearchRequest) async -> VehicleResponse? {
        let url = "\(baseURL)/vehicles/search"
        print("🔍 차량 검색 API 호출")
        print("   - URL: \(url)")
        print("   - Request: \(request)")
        
        do {
            let response: ApiResponse<VehicleResponse> = try await session.request(
                url,
                method: .post,
                parameters: request,
                encoder: JSONParameterEncoder.default
            )
                .validate()
                .serializingDecodable(ApiResponse<VehicleResponse>.self)
                .value
            
            print("✅ 차량 검색 성공")
            print("   - Status: \(response.status)")
            print("   - Success: \(response.success)")
            print("   - Message: \(response.message)")
            
            if let data = response.data {
                print("   - Total Count: \(data.totalCount)")
                print("   - Page Number: \(data.pageNumber)")
                print("   - Page Size: \(data.pageSize)")
                print("   - Vehicles Count: \(data.vehicles.count)")
            }
            
            return response.data
        } catch {
            print("❌ 차량 검색 실패")
            print("   - Error: \(error)")
            return nil
        }
    }
    
    // 일반 GET/POST 요청
    func request<T: Decodable>(
        to endpoint: APIEndpoint,
        method: HTTPMethod = .get,
        parameters: [String: Any]? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        responseType: T.Type
    ) async throws -> T {
        try await session.request(
            endpoint.url,
            method: method,
            parameters: parameters,
            encoding: encoding
        )
        .validate(statusCode: 200..<300)
        .serializingDecodable(T.self)
        .value
    }
    
    // 멀티파트 업로드 (토큰 자동 추가)
    func upload<T: Decodable>(
        to endpoint: APIEndpoint,
        request: Encodable,
        imagesData: [Data],
        responseType: T.Type
    ) async throws -> T {
        
        return try await withCheckedThrowingContinuation { continuation in
            session.upload( // session 사용
                multipartFormData: { formData in
                    // 1. JSON 추가
                    if let jsonData = try? JSONEncoder().encode(request) {
                        if let jsonString = String(data: jsonData, encoding: .utf8) {
                            print("Request JSON: \(jsonString)")
                        }
                        formData.append(
                            jsonData,
                            withName: "request",
                            mimeType: "application/json"
                        )
                    }
                    
                    // 2. 이미지들 추가
                    for (index, imageData) in imagesData.enumerated() {
                        if let image = UIImage(data: imageData),
                           let compressedData = image.jpegData(compressionQuality: 0.5) {
                            formData.append(
                                compressedData,
                                withName: "photos",
                                fileName: "image\(index).jpg",
                                mimeType: "image/jpeg"
                            )
                        }
                    }
                },
                to: endpoint.url,
                method: .post
            )
            .validate(statusCode: 200..<300)
            .responseDecodable(of: responseType) { response in
                switch response.result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// Fetch vehicle list (general or auction) and map to UI list items.
    func fetchVehicles(
        page: Int = 0,
        size: Int = 10,
        sortBy: String? = nil,
        isAuction: Bool = false
    ) async -> VehiclesPage? {
        do {
            var params: [String: Any] = [
                "page": page,
                "size": size,
                "isAuction": isAuction
            ]
            
            if let sortBy { params["sortBy"] = sortBy }
            
            let response: VehiclesResponse = try await session.request(
                "\(baseURL)/vehicles",
                method: .get,
                parameters: params
            )
                .serializingDecodable(VehiclesResponse.self)
                .value
            
            print("차량 리스트 조회 성공: \(String(describing: response.data))")
            return response.data
            //            let items = response.data.vehicles.map(mapToListItem(_:))
            //
            //            return items
        } catch {
            print("차량 리스트 조회 실패: \(error)")
            return nil
        }
    }
    
    /// Fetch vehicle detail by ID
    func fetchCarDetail(vehicleId: Int) async -> CarDetailData? {
        do {
            let response: CarDetailResponse = try await session.request(
                "\(baseURL)/vehicles/\(vehicleId)",
                method: .get
            )
                .serializingDecodable(CarDetailResponse.self)
                .value
            
            print("차량 상세 조회 성공: \(response.data)")
            return response.data
        } catch {
            print("차량 상세 조회 실패: \(error)")
            return nil
        }
    }
    
    // MARK: - Authentication APIs
    
    /// Google 로그인 API 호출
    func authenticateWithGoogle(idToken: String) async -> GoogleLoginResponse? {
        let url = "\(baseURL)/v1/users/auth/google/login"
        print("API 호출 시작")
        print("   - URL: \(url)")
        print("   - Method: POST")
        print("   - ID Token: \(idToken.prefix(50))...")
        
        do {
            let request = GoogleLoginRequest(idToken: idToken)
            print("   - Request Body: \(request)")
            
            let response = try await AF.request(
                url,
                method: .post,
                parameters: request,
                encoder: JSONParameterEncoder.default,
                headers: HTTPHeaders([
                    "Content-Type": "application/json",
                    "Accept": "application/json"
                ])
            )
                .validate() // HTTP 상태 코드 검증
                .serializingDecodable(GoogleLoginResponse.self)
                .value
            
            print("Google 로그인 API 호출 성공")
            print("   - Status: \(response.status)")
            print("   - Success: \(response.success)")
            print("   - Message: \(response.message)")
            
            if let data = response.data {
                print("   - Access Token: \(data.accessToken.prefix(20))...")
                print("   - Refresh Token: \(data.refreshToken.prefix(20))...")
                print("   - Profile Complete: \(data.profileComplete)")
            }
            
            return response
        } catch {
            print("Google 로그인 API 호출 실패")
            print("   - Error: \(error)")
            print("   - Error Type: \(type(of: error))")
            
            //            if let afError = error as? AFError {
            //                print("   - AFError Code: \(afError.responseCode ?? -1)")
            //                print("   - AFError Description: \(afError.localizedDescription)")
            //
            //                if let responseData = afError.responseData {
            //                    if let responseString = String(data: responseData, encoding: .utf8) {
            //                        print("   - Response Data: \(responseString)")
            //                    }
            //                }
            //
            //                // URL 요청 정보 출력
            //                if let request = afError.request {
            //                    print("   - Request URL: \(request.url?.absoluteString ?? "Unknown")")
            //                    print("   - Request Method: \(request.method?.rawValue ?? "Unknown")")
            //                }
            //            }
            
            return nil
        }
    }
    
    /// 로그아웃 API 호출
    func logout() async -> Bool {
        let url = "\(baseURL)/v1/users/logout"
        print("로그아웃 API 호출 시작")
        print("   - URL: \(url)")
        
        do {
            let response = try await session.request(
                url,
                method: .post
            )
                .validate()
                .serializingString()
                .value
            
            print("로그아웃 API 호출 성공")
            print("   - Response: \(response)")
            return true
        } catch {
            print("로그아웃 API 호출 실패")
            print("   - Error: \(error)")
            return false
        }
    }
    
    /// 프로필 완성 API 호출
    func completeProfile(name: String, phone: String, birthDate: String, locationCity: String) async -> Bool {
        let url = "\(baseURL)/v1/users/me/complete"
        print("프로필 완성 API 호출 시작")
        print("   - URL: \(url)")
        
        let request = ProfileCompletionRequest(
            name: name,
            phone: phone,
            locationCity: locationCity,
            birthDate: birthDate
        )
        
        print("   - Request: \(request)")
        
        do {
            let response: ProfileCompletionResponse = try await session.request(
                url,
                method: .post,
                parameters: request,
                encoder: JSONParameterEncoder.default
            )
                .validate()
                .serializingDecodable(ProfileCompletionResponse.self)
                .value
            
            print("프로필 완성 API 호출 성공")
            print("   - Status: \(response.status)")
            print("   - Success: \(response.success)")
            print("   - Message: \(response.message)")
            
            return response.success
        } catch {
            print("프로필 완성 API 호출 실패")
            print("   - Error: \(error)")
            return false
        }
    }
    
    /// 지갑 잔액 조회
    func fetchWalletBalance() async -> Int? {
        let url = "\(baseURL)/v1/wallets"
        print("지갑 잔액 조회 API 호출")
        print("   - URL: \(url)")
        
        do {
            let response: WalletResponse = try await session.request(
                url,
                method: .get
            )
                .validate()
                .serializingDecodable(WalletResponse.self)
                .value
            
            print("지갑 잔액 조회 성공")
            print("   - Status: \(response.status)")
            print("   - Success: \(response.success)")
            print("   - Message: \(response.message)")
            print("   - Balance: \(response.data)")
            
            return response.data
        } catch {
            print("지갑 잔액 조회 실패")
            print("   - Error: \(error)")
            return nil
        }
    }
    
    /// 프로필 수정
    func updateProfile(name: String, phone: String, locationCity: String, birthDate: String, profileImage: Data?) async -> Bool {
        let url = "\(baseURL)/v1/users/profile"
        print("프로필 수정 API 호출")
        print("   - URL: \(url)")
        print("   - Name: \(name)")
        print("   - Phone: \(phone)")
        print("   - Location: \(locationCity)")
        print("   - BirthDate: \(birthDate)")
        
        do {
            let userInfo = ProfileUpdateRequest(
                name: name,
                phone: phone,
                locationCity: locationCity,
                birthDate: birthDate
            )
            
            let userInfoData = try JSONEncoder().encode(userInfo)
            let userInfoString = String(data: userInfoData, encoding: .utf8) ?? ""
            
            var _: [String: Any] = [
                "userInfo": userInfoString
            ]
            
            let response: ProfileUpdateResponse = try await session.upload(
                multipartFormData: { multipartFormData in
                    // 사용자 정보 추가
                    if let data = userInfoString.data(using: .utf8) {
                        multipartFormData.append(data, withName: "userInfo")
                    }
                    
                    // 프로필 이미지 추가 (있는 경우)
                    if let imageData = profileImage {
                        multipartFormData.append(imageData, withName: "profileImage", fileName: "profile.jpg", mimeType: "image/jpeg")
                    }
                },
                to: url,
                method: .patch
            )
                .validate()
                .serializingDecodable(ProfileUpdateResponse.self)
                .value
            
            print("프로필 수정 성공")
            print("   - Status: \(response.status)")
            print("   - Success: \(response.success)")
            print("   - Message: \(response.message)")
            
            return response.success
        } catch {
            print("프로필 수정 실패")
            print("   - Error: \(error)")
            return false
        }
    }
    
    /// 사용자 프로필 정보 조회
    func fetchUserProfile() async -> UserProfileData? {
        let url = "\(baseURL)/v1/users/me"
        print("사용자 프로필 조회 API 호출")
        print("   - URL: \(url)")
        
        do {
            let response: UserProfileResponse = try await session.request(
                url,
                method: .get
            )
                .validate()
                .serializingDecodable(UserProfileResponse.self)
                .value
            
            print("사용자 프로필 조회 성공")
            print("   - Status: \(response.status)")
            print("   - Success: \(response.success)")
            print("   - Message: \(response.message)")
            
            if let userData = response.data {
                print("   - User ID: \(userData.userId)")
                print("   - Email: \(userData.email)")
                print("   - Name: \(userData.name)")
                print("   - Phone: \(userData.phone)")
                print("   - Balance: \(userData.balance)")
            }
            
            return response.data
        } catch {
            print("사용자 프로필 조회 실패")
            print("   - Error: \(error)")
            return nil
        }
    }
    
    /// 토큰 유효성 검증
    func validateToken() async -> Bool {
        let url = "\(baseURL)/v1/users/me"
        print("토큰 유효성 검증 API 호출")
        print("   - URL: \(url)")
        
        do {
            let response: UserProfileResponse = try await session.request(
                url,
                method: .get
            )
                .validate()
                .serializingDecodable(UserProfileResponse.self)
                .value
            
            print("토큰 유효성 검증 성공")
            print("   - Status: \(response.status)")
            print("   - Success: \(response.success)")
            print("   - Message: \(response.message)")
            
            if let userData = response.data {
                print("   - User ID: \(userData.userId)")
                print("   - Email: \(userData.email)")
                print("   - Name: \(userData.name)")
            }
            
            return response.success
        } catch {
            print("토큰 유효성 검증 실패")
            print("   - Error: \(error)")
            return false
        }
    }
    
    /// 토큰 재발급
    func reissueToken() async -> Bool {
        guard let refreshToken = TokenManager.shared.refreshToken else {
            print("RefreshToken이 없습니다")
            return false
        }
        
        let url = "\(baseURL)/v1/users/reissue"
        print("토큰 재발급 API 호출")
        print("   - URL: \(url)")
        
        let request = TokenReissueRequest(refreshToken: refreshToken)
        
        do {
            let response: TokenReissueResponse = try await session.request(
                url,
                method: .post,
                parameters: request,
                encoder: JSONParameterEncoder.default
            )
                .validate()
                .serializingDecodable(TokenReissueResponse.self)
                .value
            
            print("토큰 재발급 성공")
            print("   - Status: \(response.status)")
            print("   - Success: \(response.success)")
            print("   - Message: \(response.message)")
            
            if let data = response.data {
                // 새로운 토큰 저장
                TokenManager.shared.saveTokens(
                    accessToken: data.accessToken,
                    refreshToken: data.refreshToken,
                    profileComplete: data.profileComplete
                )
                print("   - 새로운 토큰 저장 완료")
            }
            
            return response.success
        } catch {
            print("토큰 재발급 실패")
            print("   - Error: \(error)")
            
            // 재발급 실패 시 토큰 삭제하여 무한 반복 방지
            print("재발급 실패로 인한 토큰 삭제")
            TokenManager.shared.clearTokens()
            
            return false
        }
    }
    
    // MARK: - Wallet APIs
    
    /// 지갑 충전
    func depositWallet(amount: Int) async -> Bool {
        let url = "\(baseURL)/v1/wallets/deposit"
        print("지갑 충전 API 호출")
        print("   - URL: \(url)")
        print("   - Amount: \(amount)")
        
        do {
            let response = try await session.request(
                url,
                method: .post,
                parameters: ["amount": amount]
            )
            .validate()
            .serializingString()
            .value
            
            print("지갑 충전 성공")
            print("   - Response: \(response)")
            return true
        } catch {
            print("지갑 충전 실패")
            print("   - Error: \(error)")
            return false
        }
    }
    
    /// 지갑 출금
    func withdrawWallet(amount: Int) async -> Bool {
        let url = "\(baseURL)/v1/wallets/withdraw"
        print("지갑 출금 API 호출")
        print("   - URL: \(url)")
        print("   - Amount: \(amount)")
        
        do {
            let response = try await session.request(
                url,
                method: .post,
                parameters: ["amount": amount]
            )
            .validate()
            .serializingString()
            .value
            
            print("지갑 출금 성공")
            print("   - Response: \(response)")
            return true
        } catch {
            print("지갑 출금 실패")
            print("   - Error: \(error)")
            return false
        }
    }
    
    // MARK: - Auction Bid API
    func submitBid(auctionId: Int, bidPrice: Int) async -> (success: Bool, message: String?) {
        let url = "\(baseURL)/auctions/bids"
        print("경매 입찰 API 호출")
        print("   - URL: \(url)")
        print("   - AuctionId: \(auctionId)")
        print("   - BidPrice: \(bidPrice)")
        
        do {
            let request = BidRequest(
                auctionId: auctionId,
                bidPrice: bidPrice
            )
            
            // 먼저 원본 응답 데이터를 받아서 상태 코드 확인
            let dataResponse = await session.request(
                url,
                method: .post,
                parameters: request,
                encoder: JSONParameterEncoder.default
            )
            .serializingData()
            .response
            
            print("경매 입찰 API 응답 수신")
            print("   - Status Code: \(dataResponse.response?.statusCode ?? -1)")
            
            // 400 에러인 경우 서버 메시지 추출
            if let statusCode = dataResponse.response?.statusCode, statusCode == 400 {
                if let responseData = dataResponse.data,
                   let responseString = String(data: responseData, encoding: .utf8) {
                    print("   - Raw Response (400): \(responseString)")
                    
                    // JSON 파싱해서 message 추출
                    if let json = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any],
                       let message = json["message"] as? String {
                        return (success: false, message: message)
                    }
                }
                return (success: false, message: "입찰에 실패했습니다.")
            }
            
            // 200 응답인 경우 정상 디코딩 시도
            if let statusCode = dataResponse.response?.statusCode, statusCode == 200 {
                if let responseData = dataResponse.data {
                    let response = try JSONDecoder().decode(BidResponse.self, from: responseData)
                    print("   - Success: \(response.success)")
                    print("   - Message: \(response.message)")
                    return (success: true, message: nil)
                }
            }
            
            return (success: false, message: "입찰에 실패했습니다.")
            
        } catch {
            print("경매 입찰 실패")
            print("   - Error: \(error)")
            return (success: false, message: "입찰에 실패했습니다.")
        }
    }
    
    // MARK: - Purchase API
    func applyPurchase(vehicleId: Int) async -> (success: Bool, message: String?) {
        let url = "\(baseURL)/v1/transactions/apply/\(vehicleId)"
        print("구매 신청 API 호출")
        print("   - URL: \(url)")
        print("   - VehicleId: \(vehicleId)")
        
        do {
            let response: PurchaseResponse = try await session.request(
                url,
                method: .post
            )
            .validate(statusCode: 200..<300)
            .serializingDecodable(PurchaseResponse.self)
            .value
            
            print("구매 신청 API 응답 수신")
            print("   - Status: \(response.status)")
            print("   - Success: \(response.success)")
            print("   - Message: \(response.message)")
            
            if let purchaseData = response.data {
                print("   - Purchase ID: \(purchaseData.id)")
                print("   - Buyer ID: \(purchaseData.buyerId)")
                print("   - Vehicle ID: \(purchaseData.vehicleId)")
                print("   - Vehicle Name: \(purchaseData.vehicleName)")
            }
            
            return (success: response.success, message: response.message)
        } catch {
            print("구매 신청 실패")
            print("   - Error: \(error)")
            return (success: false, message: "구매 신청에 실패했습니다.")
        }
    }
    
    // MARK: - Purchase Requests API
    func fetchPurchaseRequests(vehicleId: Int) async -> [PurchaseRequestData]? {
        let url = "\(baseURL)/v1/transactions/requests/\(vehicleId)"
        print("구매 신청자 목록 조회 API 호출")
        print("   - URL: \(url)")
        print("   - VehicleId: \(vehicleId)")
        
        do {
            let response: PurchaseRequestsResponse = try await session.request(
                url,
                method: .get
            )
            .validate(statusCode: 200..<300)
            .serializingDecodable(PurchaseRequestsResponse.self)
            .value
            
            print("구매 신청자 목록 조회 성공")
            print("   - Status: \(response.status)")
            print("   - Success: \(response.success)")
            print("   - Message: \(response.message)")
            print("   - 구매 신청자 수: \(response.data.count)")
            
            for purchaseRequest in response.data {
                print("   - 구매자: \(purchaseRequest.buyerName) (ID: \(purchaseRequest.buyerId))")
            }
            
            return response.data
        } catch {
            print("구매 신청자 목록 조회 실패")
            print("   - Error: \(error)")
            return nil
        }
    }
    
    /// 구매자 선택 (거래 완료)
    func selectBuyer(vehicleId: Int, buyerId: Int) async -> (success: Bool, data: TransactionCompleteData?, message: String?) {
        let url = "\(baseURL)/v1/transactions/select/\(vehicleId)"
        print("구매자 선택 API 호출")
        print("   - URL: \(url)")
        print("   - VehicleId: \(vehicleId)")
        print("   - BuyerId: \(buyerId)")
        
        do {
            let response: TransactionCompleteResponse = try await session.request(
                url,
                method: .post,
                parameters: ["buyerId": buyerId],
                encoder: URLEncodedFormParameterEncoder.default
            )
            .validate(statusCode: 200..<300)
            .serializingDecodable(TransactionCompleteResponse.self)
            .value
            
            print("구매자 선택 성공")
            print("   - Status: \(response.status)")
            print("   - Success: \(response.success)")
            print("   - Message: \(response.message)")
            
            if let data = response.data {
                print("   - TransactionId: \(data.transactionId)")
                print("   - VehicleName: \(data.vehicleName)")
                print("   - BuyerName: \(data.buyerName)")
                print("   - SellerName: \(data.sellerName)")
                print("   - FinalPrice: \(data.finalPrice)")
                print("   - Status: \(data.status)")
            }
            
            return (success: response.success, data: response.data, message: response.message)
        } catch {
            print("구매자 선택 실패")
            print("   - Error: \(error)")
            return (success: false, data: nil, message: "구매자 선택에 실패했습니다.")
        }
    }
    
    // MARK: - Favorite API
    func toggleFavorite(vehicleId: Int) async -> Bool? {
        let url = "\(baseURL)/v1/favorites/\(vehicleId)/toggle"
        print("찜 토글 API 호출")
        print("   - URL: \(url)")
        print("   - VehicleId: \(vehicleId)")
        
        do {
            let response: FavoriteToggleResponse = try await session.request(
                url,
                method: .post
            )
            .validate()
            .serializingDecodable(FavoriteToggleResponse.self)
            .value
            
            print("찜 토글 성공")
            print("   - Status: \(response.status)")
            print("   - Success: \(response.success)")
            print("   - Message: \(response.message)")
            print("   - IsFavorite: \(response.data)")
            
            return response.data
        } catch {
            print("찜 토글 실패")
            print("   - Error: \(error)")
            return nil
        }
    }
    
    // MARK: - Contract API
    /// 계약서 정보 조회
    func fetchContract(contractId: Int) async -> ContractData? {
        let url = "\(baseURL)/v1/contracts/\(contractId)"
        print("계약서 정보 조회 API 호출")
        print("   - URL: \(url)")
        print("   - ContractId: \(contractId)")
        
        do {
            // 먼저 원본 응답 데이터를 받아서 확인
            let dataResponse = await session.request(
                url,
                method: .get
            )
            .serializingData()
            .response
            
            print("계약서 정보 조회 API 응답 수신")
            print("   - Status Code: \(dataResponse.response?.statusCode ?? -1)")
            
            if let responseData = dataResponse.data,
               let responseString = String(data: responseData, encoding: .utf8) {
                print("   - Raw Response: \(responseString)")
            }
            
            // 200 응답인 경우에만 디코딩 시도
            if let statusCode = dataResponse.response?.statusCode, statusCode == 200 {
                if let responseData = dataResponse.data {
                    let response = try JSONDecoder().decode(ContractResponse.self, from: responseData)
                    print("계약서 정보 조회 성공")
                    print("   - Status: \(response.status)")
                    print("   - Success: \(response.success)")
                    print("   - Message: \(response.message)")
                    
                    if let contractData = response.data {
                        print("   - ContractId: \(contractData.contractId)")
                        print("   - TransactionId: \(contractData.transactionId)")
                        print("   - BuyerName: \(contractData.buyerName)")
                        print("   - SellerName: \(contractData.sellerName)")
                        print("   - Status: \(contractData.status)")
                        print("   - SignedAt: \(contractData.signedAt)")
                        print("   - ContractPdfUrl: \(contractData.contractPdfUrl)")
                    }
                    
                    return response.data
                }
            }
            
            return nil
        } catch {
            print("계약서 정보 조회 실패")
            print("   - Error: \(error)")
            print("   - Error Type: \(type(of: error))")
            
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .keyNotFound(let key, let context):
                    print("   - Missing Key: \(key)")
                    print("   - Context: \(context)")
                case .typeMismatch(let type, let context):
                    print("   - Type Mismatch: \(type)")
                    print("   - Context: \(context)")
                case .valueNotFound(let type, let context):
                    print("   - Value Not Found: \(type)")
                    print("   - Context: \(context)")
                case .dataCorrupted(let context):
                    print("   - Data Corrupted: \(context)")
                @unknown default:
                    print("   - Unknown Decoding Error")
                }
            }
            
            return nil
        }
    }
    
    /// 계약서 PDF 다운로드
    func fetchContractPDF(contractId: Int) async -> Data? {
        let url = "\(baseURL)/v1/contracts/\(contractId)/pdf"
        print("계약서 PDF 다운로드 API 호출")
        print("   - URL: \(url)")
        print("   - ContractId: \(contractId)")
        
        do {
            let response = try await session.request(
                url,
                method: .get
            )
            .validate(statusCode: 200..<300)
            .serializingData()
            .value
            
            print("계약서 PDF 다운로드 성공")
            print("   - PDF Size: \(response.count) bytes")
            
            return response
        } catch {
            print("계약서 PDF 다운로드 실패")
            print("   - Error: \(error)")
            return nil
        }
    }
    
    // MARK: - Transaction History API
    /// 판매내역 조회
    func fetchSalesHistory() async -> [TransactionHistoryData]? {
        let url = "\(baseURL)/v1/transactions/my/sales"
        print("판매내역 조회 API 호출")
        print("   - URL: \(url)")
        
        do {
            let response: TransactionHistoryResponse = try await session.request(
                url,
                method: .get
            )
            .validate(statusCode: 200..<300)
            .serializingDecodable(TransactionHistoryResponse.self)
            .value
            
            print("판매내역 조회 성공")
            print("   - Status: \(response.status)")
            print("   - Success: \(response.success)")
            print("   - Message: \(response.message)")
            print("   - 판매내역 수: \(response.data.count)")
            
            for transaction in response.data {
                print("   - 거래: \(transaction.vehicleName) - \(transaction.buyerName) - \(Formatters.priceText(won: transaction.finalPrice))")
            }
            
            return response.data
        } catch {
            print("판매내역 조회 실패")
            print("   - Error: \(error)")
            return nil
        }
    }
    
    /// 구매내역 조회
    func fetchPurchaseHistory() async -> [TransactionHistoryData]? {
        let url = "\(baseURL)/v1/transactions/my/purchases"
        print("구매내역 조회 API 호출")
        print("   - URL: \(url)")
        
        do {
            let response: TransactionHistoryResponse = try await session.request(
                url,
                method: .get
            )
            .validate(statusCode: 200..<300)
            .serializingDecodable(TransactionHistoryResponse.self)
            .value
            
            print("구매내역 조회 성공")
            print("   - Status: \(response.status)")
            print("   - Success: \(response.success)")
            print("   - Message: \(response.message)")
            print("   - 구매내역 수: \(response.data.count)")
            
            for transaction in response.data {
                print("   - 거래: \(transaction.vehicleName) - \(transaction.sellerName) - \(Formatters.priceText(won: transaction.finalPrice))")
            }
            
            return response.data
        } catch {
            print("구매내역 조회 실패")
            print("   - Error: \(error)")
            return nil
        }
    }
    
    // MARK: - Recent Views API
    func fetchRecentViews() async -> [RecentViewData]? {
        let url = "\(baseURL)/v1/recent-views"
        
        do {
            let response = try await AF.request(url, method: .get, interceptor: TokenInterceptor())
                .validate()
                .serializingDecodable(RecentViewsResponse.self)
                .value
            
            return response.data
        } catch {
            print("Recent views fetch failed: \(error)")
            return nil
        }
    }
    
    // MARK: - Favorites API
    func fetchFavorites() async -> [FavoriteData]? {
        let url = "\(baseURL)/v1/favorites"
        
        do {
            let response = try await AF.request(url, method: .get, interceptor: TokenInterceptor())
                .validate()
                .serializingDecodable(FavoritesResponse.self)
                .value
            
            return response.data
        } catch {
            print("Favorites fetch failed: \(error)")
            return nil
        }
    }
}
