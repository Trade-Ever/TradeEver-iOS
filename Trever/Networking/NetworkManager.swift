import Foundation
import Alamofire

// MARK: - Token Interceptor
final class TokenInterceptor: RequestInterceptor, @unchecked Sendable {
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
        // 401 에러인 경우 토큰 재발급 시도
        if let response = request.task?.response as? HTTPURLResponse,
           response.statusCode == 401 {
            
            print("🔄 401 에러 감지 - 토큰 재발급 시도")
            
            Task {
                let success = await NetworkManager.shared.reissueToken()
                
                if success {
                    print("✅ 토큰 재발급 성공 - 요청 재시도")
                    completion(.retry)
                } else {
                    print("❌ 토큰 재발급 실패 - 로그아웃 처리")
                    await AuthViewModel.shared.signOut()
                    completion(.doNotRetry)
                }
            }
        } else {
            completion(.doNotRetry)
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
        print("🌐 API 호출 시작")
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
            
            print("✅ Google 로그인 API 호출 성공")
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
            print("❌ Google 로그인 API 호출 실패")
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
        print("🚪 로그아웃 API 호출 시작")
        print("   - URL: \(url)")
        
        do {
            let response = try await session.request(
                url,
                method: .post
            )
            .validate()
            .serializingString()
            .value
            
            print("✅ 로그아웃 API 호출 성공")
            print("   - Response: \(response)")
            return true
        } catch {
            print("❌ 로그아웃 API 호출 실패")
            print("   - Error: \(error)")
            return false
        }
    }
    
    /// 프로필 완성 API 호출
    func completeProfile(name: String, phone: String, birthDate: String, locationCity: String) async -> Bool {
        let url = "\(baseURL)/v1/users/me/complete"
        print("📝 프로필 완성 API 호출 시작")
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
            
            print("✅ 프로필 완성 API 호출 성공")
            print("   - Status: \(response.status)")
            print("   - Success: \(response.success)")
            print("   - Message: \(response.message)")
            
            return response.success
        } catch {
            print("❌ 프로필 완성 API 호출 실패")
            print("   - Error: \(error)")
            return false
        }
    }
    
    /// 지갑 잔액 조회
    func fetchWalletBalance() async -> Int? {
        let url = "\(baseURL)/v1/wallets"
        print("💰 지갑 잔액 조회 API 호출")
        print("   - URL: \(url)")
        
        do {
            let response: WalletResponse = try await session.request(
                url,
                method: .get
            )
            .validate()
            .serializingDecodable(WalletResponse.self)
            .value
            
            print("✅ 지갑 잔액 조회 성공")
            print("   - Status: \(response.status)")
            print("   - Success: \(response.success)")
            print("   - Message: \(response.message)")
            print("   - Balance: \(response.data)")
            
            return response.data
        } catch {
            print("❌ 지갑 잔액 조회 실패")
            print("   - Error: \(error)")
            return nil
        }
    }
    
    /// 프로필 수정
    func updateProfile(name: String, phone: String, locationCity: String, birthDate: String, profileImage: Data?) async -> Bool {
        let url = "\(baseURL)/v1/users/profile"
        print("📝 프로필 수정 API 호출")
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
            
            print("✅ 프로필 수정 성공")
            print("   - Status: \(response.status)")
            print("   - Success: \(response.success)")
            print("   - Message: \(response.message)")
            
            return response.success
        } catch {
            print("❌ 프로필 수정 실패")
            print("   - Error: \(error)")
            return false
        }
    }
    
    /// 사용자 프로필 정보 조회
    func fetchUserProfile() async -> UserProfileData? {
        let url = "\(baseURL)/v1/users/me"
        print("👤 사용자 프로필 조회 API 호출")
        print("   - URL: \(url)")
        
        do {
            let response: UserProfileResponse = try await session.request(
                url,
                method: .get
            )
            .validate()
            .serializingDecodable(UserProfileResponse.self)
            .value
            
            print("✅ 사용자 프로필 조회 성공")
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
            print("❌ 사용자 프로필 조회 실패")
            print("   - Error: \(error)")
            return nil
        }
    }
    
    /// 토큰 유효성 검증
    func validateToken() async -> Bool {
        let url = "\(baseURL)/v1/users/me"
        print("🔍 토큰 유효성 검증 API 호출")
        print("   - URL: \(url)")
        
        do {
            let response: UserProfileResponse = try await session.request(
                url,
                method: .get
            )
            .validate()
            .serializingDecodable(UserProfileResponse.self)
            .value
            
            print("✅ 토큰 유효성 검증 성공")
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
            print("❌ 토큰 유효성 검증 실패")
            print("   - Error: \(error)")
            return false
        }
    }
    
    /// 토큰 재발급
    func reissueToken() async -> Bool {
        guard let refreshToken = TokenManager.shared.refreshToken else {
            print("❌ RefreshToken이 없습니다")
            return false
        }
        
        let url = "\(baseURL)/v1/users/reissue"
        print("🔄 토큰 재발급 API 호출")
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
            
            print("✅ 토큰 재발급 성공")
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
            print("❌ 토큰 재발급 실패")
            print("   - Error: \(error)")
            return false
        }
    }
    
    // MARK: - Wallet APIs
    
    /// 지갑 충전
    func depositWallet(amount: Int) async -> Bool {
        let url = "\(baseURL)/v1/wallets/deposit"
        print("💰 지갑 충전 API 호출")
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
            
            print("✅ 지갑 충전 성공")
            print("   - Response: \(response)")
            return true
        } catch {
            print("❌ 지갑 충전 실패")
            print("   - Error: \(error)")
            return false
        }
    }
    
    /// 지갑 출금
    func withdrawWallet(amount: Int) async -> Bool {
        let url = "\(baseURL)/v1/wallets/withdraw"
        print("💰 지갑 출금 API 호출")
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
            
            print("✅ 지갑 출금 성공")
            print("   - Response: \(response)")
            return true
        } catch {
            print("❌ 지갑 출금 실패")
            print("   - Error: \(error)")
            return false
        }
    }
    
    // MARK: - Auction Bid API
    func submitBid(auctionId: Int, bidPrice: Int) async -> Bool {
        let url = "\(baseURL)/auctions/bids"
        print("💰 경매 입찰 API 호출")
        print("   - URL: \(url)")
        print("   - AuctionId: \(auctionId)")
        print("   - BidPrice: \(bidPrice)")
        
        do {
            let request = BidRequest(
                auctionId: auctionId,
                bidPrice: bidPrice
            )
            
            let response: BidResponse = try await session.request(
                url,
                method: .post,
                parameters: request,
                encoder: JSONParameterEncoder.default
            )
            .validate()
            .serializingDecodable(BidResponse.self)
            .value
            
            print("✅ 경매 입찰 성공")
            print("   - Status: \(response.status)")
            print("   - Success: \(response.success)")
            print("   - Message: \(response.message)")
            
            return response.success
        } catch {
            print("❌ 경매 입찰 실패")
            print("   - Error: \(error)")
            return false
        }
    }
    
    // MARK: - Favorite API
    func toggleFavorite(vehicleId: Int) async -> Bool? {
        let url = "\(baseURL)/v1/favorites/\(vehicleId)/toggle"
        print("❤️ 찜 토글 API 호출")
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
            
            print("✅ 찜 토글 성공")
            print("   - Status: \(response.status)")
            print("   - Success: \(response.success)")
            print("   - Message: \(response.message)")
            print("   - IsFavorite: \(response.data)")
            
            return response.data
        } catch {
            print("❌ 찜 토글 실패")
            print("   - Error: \(error)")
            return nil
        }
    }
    
    
}
