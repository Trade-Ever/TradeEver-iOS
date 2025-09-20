import Foundation

@MainActor
final class AuctionListViewModel: ObservableObject {
    @Published var vehicleItems: VehiclesPage?
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var error: String?
    @Published var liveByAuctionId: [Int: AuctionLive] = [:]
    
    private let networkManager = NetworkManager.shared
    private var currentPage = 0
    private let pageSize = 20
    private var hasMorePages = true
    private var currentTask: Task<Void, Never>?
    private var liveHandles: [Int: UInt] = [:]
    
    func fetchAuctionVehicles() async {
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
                isAuction: true
            )
            
            // Task가 취소되었는지 확인
            guard !Task.isCancelled else { return }
            
            await MainActor.run { [weak self] in
                if let data = result {
                    self?.vehicleItems = data
                    self?.hasMorePages = data.vehicles.count == pageSize
                    self?.resubscribeLiveAuctions()
                } else {
                    self?.error = "경매 차량 정보를 불러올 수 없습니다."
                }
                self?.isLoading = false
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
            isAuction: true
        )
        
        await MainActor.run { [weak self] in
            if let data = result {
                let newVehicles = data.vehicles
                self?.vehicleItems?.vehicles.append(contentsOf: newVehicles)
                self?.hasMorePages = newVehicles.count == pageSize
                self?.subscribeLiveAuctions(for: newVehicles)
            }
            self?.isLoadingMore = false
        }
    }

    private func resubscribeLiveAuctions() {
        // remove previous
        for (aid, h) in liveHandles { FirebaseAuctionService.shared.removeObserver(auctionId: aid, handle: h) }
        liveHandles.removeAll()
        // subscribe for current list
        subscribeLiveAuctions(for: vehicleItems?.vehicles ?? [])
    }

    private func subscribeLiveAuctions(for vehicles: [VehicleAPIItem]) {
        for v in vehicles {
            guard let aid64 = v.auctionId else { continue }
            let aid = Int(aid64)
            if liveHandles[aid] != nil { continue }
            let handle = FirebaseAuctionService.shared.observeAuction(auctionId: aid) { [weak self] live in
                guard let live else { return }
                self?.liveByAuctionId[aid] = live
            }
            liveHandles[aid] = handle
        }
    }
}

