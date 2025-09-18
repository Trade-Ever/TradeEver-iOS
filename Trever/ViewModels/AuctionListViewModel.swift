import Foundation

final class AuctionListViewModel: ObservableObject {
    @Published var items: [CarListItem] = []
    private let service: VehicleService

    init(service: VehicleService = MockVehicleService.shared) {
        self.service = service
    }

    @MainActor
    func load() async {
        do {
            let dtos = try await service.fetchAuctionList()
            items = dtos.map(DTOMapper.toListItem)
        } catch {
            print("Auction list load failed: \(error)")
        }
    }
}

