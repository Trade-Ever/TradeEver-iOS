import Foundation

@MainActor
final class CarDetailViewModel: ObservableObject {
    @Published var detail: CarDetail?
    @Published var isLoading = false
    @Published var error: String?

    private let service: VehicleService
    private let vehicleId: Int64

    init(vehicleId: Int64, service: VehicleService = MockVehicleService.shared) {
        self.vehicleId = vehicleId
        self.service = service
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let dto = try await service.fetchDetail(vehicleId: vehicleId)
            detail = DTOMapper.toDetail(dto)
        } catch {
            self.error = String(describing: error)
        }
    }
}

