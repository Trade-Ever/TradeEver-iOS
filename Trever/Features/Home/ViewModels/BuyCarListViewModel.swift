import Foundation
import Combine

@MainActor
final class BuyCarListViewModel: ObservableObject {
//    @Published var items: [CarListItem] = []
    @Published var vehicleItems: VehiclesPage?
    
    private let networkMananger = NetworkManager.shared
    
    func fetchVehicles() async {
        let result = await networkMananger.fetchVehicles(
            page: 0,
            size: 20,
            sortBy: nil,
            isAuction: false
        )
        await MainActor.run {
            self.vehicleItems = result
        }
    }
    
//    private let service: VehicleService
//
//    init(service: VehicleService = MockVehicleService.shared) {
//        self.service = service
//    }
//
//    @MainActor
//    func load() async {
//        // 1) Try API via Alamofire
//        if let apiItems = try? await NetworkManager.shared.fetchVehicles(page: 0, size: 20, sortBy: nil, isAuction: false) {
//            self.items = apiItems
//            return
//        }
//        // 2) Fallback to mock service
//        do {
//            let dtos = try await service.fetchBuyList()
//            items = dtos.map(DTOMapper.toListItem)
//        } catch {
//            print("Buy list load failed: \(error)")
//        }
//    }
}
