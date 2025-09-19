import SwiftUI

struct AuctionView: View {
    @StateObject private var vm = AuctionListViewModel()
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(vm.items) { item in
                    NavigationLink {
                        CarDetailScreen(vehicleId: item.backendId ?? 0)
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
        .task { await vm.load() }
    }
}

#Preview { AuctionView() }
