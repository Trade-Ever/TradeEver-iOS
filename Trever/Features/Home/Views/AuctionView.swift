import SwiftUI

struct AuctionView: View {
    @StateObject private var vm = AuctionListViewModel()
    
    var body: some View {
        Group {
            if let vehicles = vm.vehicleItems?.vehicles {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(vehicles) { vehicle in
                            NavigationLink {
                                CarDetailScreen(vehicleId: Int(vehicle.id), auctionId: vehicle.auctionId.map(Int.init))
                            } label: {
                                AuctionCarListItemView(
                                    vehicle: vehicle,
                                    live: vehicle.auctionId.flatMap { vm.liveByAuctionId[Int($0)] }
                                )
                            }
                            .buttonStyle(.plain)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .onAppear {
                                // 무한 스크롤: 마지막 아이템이 나타날 때 다음 페이지 로드
                                if vehicle.id == vehicles.last?.id {
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
                }
                .refreshable {
                    await vm.fetchAuctionVehicles()
                }
            } else if vm.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = vm.error {
                ContentUnavailableView("로드 실패", systemImage: "exclamationmark.triangle", description: Text(error))
            } else {
                ContentUnavailableView("경매 차량이 없습니다", systemImage: "car")
            }
        }
        .navigationTitle("경매")
        .task { await vm.fetchAuctionVehicles() }
    }
}

#Preview { AuctionView() }
