import SwiftUI

struct BuyCarView: View {
    private let items = CarRepository.sampleBuyList
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
        .navigationTitle("내차사기")
    }
}

#Preview { BuyCarView() }
