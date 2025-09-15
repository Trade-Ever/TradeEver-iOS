import SwiftUI

struct BuyCarView: View {
    var body: some View {
        NavigationStack {
            List {
                ForEach(0..<8) { _ in
                    CarListItemView(
                        imageName: "Car Item",
                        title: "Torress EVX E7",
                        year: "2024식",
                        mileage: "3.8만km",
                        tags: ["비흡연자", "무사고", "정비이력"],
                        priceText: "3,300만원",
                        isAuction: false
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                }
            }
            .padding(.bottom, 19)
            .listStyle(.plain)
            .navigationTitle("내차사기")
            .toolbar { ToolbarItem(placement: .topBarLeading) { Text("") } }
        }
    }
}

#Preview { BuyCarView() }
