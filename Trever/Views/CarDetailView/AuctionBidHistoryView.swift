import SwiftUI

struct AuctionBidHistoryView: View {
    let vehicleId: Int64

    // In real app, this will be provided by a ViewModel subscribing to a REST/websocket source
    @State private var bids: [BidEntry] = []

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(bids) { bid in
                    BidListItem(bid: bid)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("입찰 내역")
        .navigationBarTitleDisplayMode(.inline)
        .tabBarHidden(true)
        .onAppear { load() }
    }

    private func load() {
        Task { @MainActor in
            if let dto = try? await MockVehicleService.shared.fetchDetail(vehicleId: vehicleId) {
                bids = (dto.auction?.bids ?? []).map { BidEntry(bidderName: "사용자 #\($0.bidder_id)", priceWon: $0.bid_price, placedAt: $0.created_at) }
            } else {
                bids = []
            }
        }
    }
}

#Preview {
    NavigationStack {
        AuctionBidHistoryView(vehicleId: 101)
    }
}
