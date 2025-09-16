import SwiftUI

struct AuctionBidHistoryView: View {
    let carId: UUID

    // In real app, this will be provided by a ViewModel subscribing to a REST/websocket source
    @State private var bids: [BidEntry] = []

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(bids) { bid in
                    bidRow(bid)
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

    private func bidRow(_ bid: BidEntry) -> some View {
        HStack {
            Circle().fill(Color.grey100).frame(width: 36, height: 36)
                .overlay(Image(systemName: "person").foregroundStyle(.secondary))
            VStack(alignment: .leading, spacing: 2) {
                Text(bid.bidderName)
                    .font(.subheadline)
                Text(Formatters.dateTimeText(bid.placedAt))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(Formatters.priceText(won: bid.priceWon))
                .font(.headline).bold()
                .foregroundStyle(Color.priceGreen)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
        )
    }
}

#Preview {
    NavigationStack {
        AuctionBidHistoryView(carId: UUID())
    }
}

