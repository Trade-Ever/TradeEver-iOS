import Foundation
import Alamofire

final class NetworkManager {
    static let shared = NetworkManager()
//    private init() {}

    private let baseURL = "https://www.trever.store/api"
//    private let baseURL = "http://54.180.107.111:8080/api"

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
            
            let response: VehiclesResponse = try await AF.request(
                "\(baseURL)/vehicles",
                method: .get,
                parameters: params,
                headers: authenticatedHeaders()
            )
            .serializingDecodable(VehiclesResponse.self/*, decoder: jsonDecoder*/)
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
            let response: CarDetailResponse = try await AF.request(
                "\(baseURL)/vehicles/\(vehicleId)",
                method: .get,
                headers: authenticatedHeaders()
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
            let response = try await AF.request(
                url,
                method: .post,
                headers: authenticatedHeaders()
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
            let response: ProfileCompletionResponse = try await AF.request(
                url,
                method: .post,
                parameters: request,
                encoder: JSONParameterEncoder.default,
                headers: authenticatedHeaders()
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
    
    /// 인증이 필요한 API 호출을 위한 헤더 생성
    func authenticatedHeaders() -> HTTPHeaders {
        var headers = HTTPHeaders.default
        if let authHeader = TokenManager.shared.authorizationHeader.first {
            headers.add(name: authHeader.key, value: authHeader.value)
        }
        return headers
    }
}
