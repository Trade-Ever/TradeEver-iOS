import SwiftUI

struct AuctionBidHistoryView: View {
    let vehicleId: Int64
    let auctionId: Int?

    @EnvironmentObject private var vm: CarDetailViewModel

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
        .background(Color.secondaryBackground)
        .navigationTitle("입찰 내역")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // If navigated from detail with vm, use its allBids
            let _ = vm
        }
    }
    
    private var bids: [BidEntry] { vm.allBids }
}

#Preview {
    NavigationStack {
        AuctionBidHistoryView(vehicleId: 101, auctionId: 1)
    }
}
