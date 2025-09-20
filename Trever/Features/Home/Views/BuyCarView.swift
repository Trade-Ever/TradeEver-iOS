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
                            CarDetailScreen(vehicleId: Int(vehicle.id))
                        } label: {
                            CarListItemView(apiModel: vehicle)
                        }
                        .buttonStyle(.plain)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .onAppear {
                            // 무한 스크롤: 마지막 아이템이 나타날 때 다음 페이지 로드
                            if vehicle.id == vm.vehicleItems?.vehicles.last?.id {
                                Task {
                                    await vm.loadMoreVehicles()
                                }
                            }
                        }
                    }
                    
                    // 로딩 인디케이터
                    if vm.isLoadingMore {
                        HStack {
                            Spacer()
                            ProgressView()
                                .padding()
                            Spacer()
                        }
                    }
                }
                .padding(.top, searchBarHeight + 16)
            }
            .refreshable {
                await vm.fetchVehicles()
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
