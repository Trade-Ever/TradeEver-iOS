import Foundation
import Alamofire

// MARK: - API Response DTOs for /api/vehicles

// MARK: - Network Layer

final class NetworkManager {
    static let shared = NetworkManager()
//    private init() {}

    private let baseURL = "https://www.trever.store/api"

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
                parameters: params
            )
            .serializingDecodable(VehiclesResponse.self/*, decoder: jsonDecoder*/)
            .value
            
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
                method: .get
            )
            .serializingDecodable(CarDetailResponse.self)
            .value
            
            return response.data
        } catch {
            print("차량 상세 조회 실패: \(error)")
            return nil
        }
    }
}
