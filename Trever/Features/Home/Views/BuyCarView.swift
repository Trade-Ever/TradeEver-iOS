import SwiftUI

struct BuyCarView: View {
    @StateObject private var vm = BuyCarListViewModel()
    private let searchBarHeight: CGFloat = 48
    var body: some View {
        ZStack(alignment: .top) {
            // Scrollable list with top padding to avoid overlap with floating search
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(vm.vehicleItems?.vehicles ?? []) { vehicle in
                        NavigationLink {
                            CarDetailScreen(vehicleId: vehicle.id)
                        } label: {
                            CarListItemView(apiModel: vehicle)
                        }
                        .buttonStyle(.plain)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.top, searchBarHeight + 16)
            }

            // Floating search button
            NavigationLink {
                SearchView().tabBarHidden(true)
            } label: {
                SearchBarButton(title: "차량 검색") {}
                    .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .task { await vm.fetchVehicles() }
    }
}

#Preview { BuyCarView() }
