import Foundation

@MainActor
final class CarDetailViewModel: ObservableObject {
    @Published var detail: CarDetail?
    @Published var isLoading = false
    @Published var error: String?
    @Published var liveAuction: AuctionLive?
    @Published var topBids: [BidEntry] = []
    @Published var allBids: [BidEntry] = []

    private let networkManager = NetworkManager.shared
    private let vehicleId: Int
    private let initialAuctionId: Int?

    init(vehicleId: Int, auctionId: Int? = nil) {
        self.vehicleId = vehicleId
        self.initialAuctionId = auctionId
        // If we already know auctionId, start live subscription immediately
        if let aid = auctionId {
            subscribeAuction(auctionId: aid)
            subscribeBids(auctionId: aid)
        }
    }

    private var liveHandle: UInt?
    nonisolated(unsafe) private var liveHandleUnsafe: UInt?
    nonisolated(unsafe) private var subscribedAuctionIdUnsafe: Int?
    private var bidsHandle: UInt?

    func load() async {
        isLoading = true
        defer { isLoading = false }
        
        let result = await networkManager.fetchCarDetail(vehicleId: vehicleId)
        
        await MainActor.run { [weak self] in
            if let data = result {
                self?.detail = data
                // subscribe live by auctionId first, else vehicleId
                if let aid = data.auctionId {
                    self?.subscribeAuction(auctionId: aid)
                    self?.subscribeBids(auctionId: aid)
                } else if self?.initialAuctionId == nil { // only fallback if we didn't already subscribe by initial id
                    self?.subscribeAuctionByVehicleId(vehicleId: data.id)
                }
            } else {
                self?.error = "차량 정보를 불러올 수 없습니다."
            }
        }
    }

    private nonisolated func subscribeAuction(auctionId: Int) {
        let handle = FirebaseAuctionService.shared.observeAuction(auctionId: auctionId) { [weak self] live in
            Task { @MainActor in self?.liveAuction = live }
        }
        // store safely on main actor and also in unsafe copies for deinit
        Task { @MainActor in
            self.liveHandle = handle
            self.liveHandleUnsafe = handle
            self.subscribedAuctionIdUnsafe = auctionId
        }
    }

    private nonisolated func subscribeAuctionByVehicleId(vehicleId: Int) {
        _ = FirebaseAuctionService.shared.observeAuctionByVehicleIdContinuous(vehicleId: vehicleId) { [weak self] live in
            Task { @MainActor in
                self?.liveAuction = live
                if let aid = live?.id, self?.bidsHandle == nil {
                    self?.subscribeBids(auctionId: aid)
                    self?.subscribedAuctionIdUnsafe = aid
                }
            }
        }
    }

    private func subscribeBids(auctionId: Int) {
        bidsHandle = FirebaseAuctionService.shared.observeBids(auctionId: auctionId) { [weak self] bids in
            Task { @MainActor in
                self?.allBids = bids
                self?.topBids = Array(bids.prefix(3))
            }
        }
    }

    deinit {
        if let aid = subscribedAuctionIdUnsafe, let h = liveHandleUnsafe {
            FirebaseAuctionService.shared.removeObserver(auctionId: aid, handle: h)
        }
        if let aid = subscribedAuctionIdUnsafe, let bh = bidsHandle {
            FirebaseAuctionService.shared.removeBidsObserver(auctionId: aid, handle: bh)
        }
    }
}

