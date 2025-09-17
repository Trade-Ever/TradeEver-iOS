import SwiftUI

struct AuctionView: View {
    private let items = CarRepository.sampleAuctionList
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(items) { item in
                    NavigationLink {
                        CarDetailView(detail: CarRepository.mockDetail(from: item))
                    } label: {
                        CarListItemView(model: item)
                    }
                    .buttonStyle(.plain)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                }
            }
        }
        .navigationTitle("경매")
    }
}

#Preview { AuctionView() }
