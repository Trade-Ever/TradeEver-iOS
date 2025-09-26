import SwiftUI
import Lottie

struct AuctionView: View {
    @ObservedObject private var vm = AuctionListViewModel.shared
    
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
                VStack(spacing: 20) {
                    LottieView(animation: .named("empty_list"))
                        .playing(loopMode: .loop)
                        .frame(width: 200, height: 200)
                    
                    VStack(spacing: 8) {
                        Text("경매 차량이 없습니다")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("새로운 경매 차량이 등록되면\n알려드릴게요")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button(action: {
                        Task {
                            await vm.fetchAuctionVehicles()
                        }
                    }) {
                        Text("새로고침")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 120, height: 44)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))
            }
        }
        .navigationTitle("경매")
        .onAppear {
            // 데이터가 없을 때만 로드
            if vm.vehicleItems == nil && !vm.isLoading {
                Task {
                    await vm.fetchAuctionVehicles()
                }
            }
        }
    }
}

#Preview { AuctionView() }
