import SwiftUI

struct AuctionBidHistoryView: View {
    let carId: UUID

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
        .onAppear { load() }
    }

    private func load() {
        // Replace with repository call (async) later
        bids = CarRepository.mockBids(for: carId)
    }
}

#Preview {
    NavigationStack {
        AuctionBidHistoryView(carId: UUID())
    }
}

