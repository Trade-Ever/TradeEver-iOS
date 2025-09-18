import Foundation
import Combine

final class BuyCarListViewModel: ObservableObject {
    @Published var items: [CarListItem] = []
    private let service: VehicleService

    init(service: VehicleService = MockVehicleService.shared) {
        self.service = service
    }

    @MainActor
    func load() async {
        do {
            let dtos = try await service.fetchBuyList()
            items = dtos.map(DTOMapper.toListItem)
        } catch {
            print("Buy list load failed: \(error)")
        }
    }
}

