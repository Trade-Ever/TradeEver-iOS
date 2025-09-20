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

//    private var jsonDecoder: JSONDecoder {
//        let d = JSONDecoder()
//        d.keyDecodingStrategy = .useDefaultKeys
//        return d
//    }
//
//    private func mapToListItem(_ v: VehicleAPIItem) -> CarListItem {
//        // Build title
//        let displayTitle = v.carName ?? v.model ?? "차량"
//        let year = v.year_value
//        let mileage = v.mileage
//        let thumb = v.representativePhotoUrl
//
//        // Tags
//        var tags: [String] = []
//        if let vt = v.vehicleTypeName, !vt.isEmpty { tags.append(vt) }
//        if let ft = v.fuelType, !ft.isEmpty { tags.append(ft) }
//        if let tr = v.transmission, !tr.isEmpty { tags.append(tr) }
//        if tags.isEmpty, let status = v.vehicleStatus { tags.append(status) }
//
//        // Auction flags
//        let auction = (v.isAuction.uppercased() == "Y")
//        let endAtDate = parseDate(v.endAt)
//
//        // Prices
//        let start = v.startPrice ?? v.price ?? 0
//        let price = v.currentPrice ?? v.price ?? start
//
//        return CarListItem(
//            id: UUID(),
//            backendId: v.id,
//            title: displayTitle,
//            subTitle: nil,
//            year: year,
//            mileageKm: mileage,
//            thumbnailName: thumb,
//            tags: tags,
//            priceWon: price,
//            startPrice: start,
//            isAuction: auction,
//            auctionEndsAt: endAtDate,
//            likes: v.favoriteCount ?? 0
//        )
//    }
//
//    private func parseDate(_ s: String?) -> Date? {
//        guard let s else { return nil }
//        // Try ISO8601 with fractional seconds
//        let iso = ISO8601DateFormatter()
//        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
//        if let d = iso.date(from: s) { return d }
//        // Fallback without fractional
//        iso.formatOptions = [.withInternetDateTime]
//        return iso.date(from: s)
//    }
}
