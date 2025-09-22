import Foundation
import Combine

@MainActor
final class BuyCarListViewModel: ObservableObject {
    static let shared = BuyCarListViewModel()
    
    @Published var vehicleItems: VehiclesPage?
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var error: String?
    
    private let networkManager = NetworkManager.shared
    private var currentPage = 0
    private let pageSize = 20
    private var hasMorePages = true
    private var currentTask: Task<Void, Never>?
    
    private init() {}
    
    func fetchVehicles() async {
        // 이전 요청이 있으면 취소
        currentTask?.cancel()
        
        currentPage = 0
        hasMorePages = true
        isLoading = true
        error = nil
        
        currentTask = Task {
            let result = await networkManager.fetchVehicles(
                page: currentPage,
                size: pageSize,
                sortBy: nil,
                isAuction: false
            )
            
            // Task가 취소되었는지 확인
            guard !Task.isCancelled else { return }
            
            await MainActor.run {
                if let data = result {
                    vehicleItems = data
                    hasMorePages = data.vehicles.count == pageSize
                } else {
                    error = "차량 정보를 불러올 수 없습니다."
                }
                isLoading = false
            }
        }
        
        await currentTask?.value
    }
    
    func loadMoreVehicles() async {
        guard !isLoadingMore && hasMorePages else { return }
        
        isLoadingMore = true
        currentPage += 1
        
        let result = await networkManager.fetchVehicles(
            page: currentPage,
            size: pageSize,
            sortBy: nil,
            isAuction: false
        )
        
        await MainActor.run {
            if let data = result {
                let newVehicles = data.vehicles
                vehicleItems?.vehicles.append(contentsOf: newVehicles)
                hasMorePages = newVehicles.count == pageSize
            }
            isLoadingMore = false
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
