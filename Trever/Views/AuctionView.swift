import SwiftUI

struct AuctionView: View {
    var body: some View {
        NavigationStack {
            List {
                ForEach(0..<5) { idx in
                    CarListItemView(
                        imageName: "Car Item1",
                        title: "Taycan",
                        year: "2024식",
                        mileage: "1.6만km",
                        tags: ["비흡연자", "무사고", "정비이력"],
                        priceText: "1억 4,190만원",
                        isAuction: true,
                        timerText: "4분"
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                }
            }
            .padding(.bottom, 19)
            .listStyle(.plain)
            .navigationTitle("경매")
        }
    }
}

#Preview { AuctionView() }
