import SwiftUI
import Lottie

struct BuyCarView: View {
    @State private var showingSearchView = false
    @ObservedObject private var vm = BuyCarListViewModel.shared
    private let searchBarHeight: CGFloat = 48
    
    var body: some View {
        ZStack(alignment: .top) {
            Group {
                if let vehicles = vm.vehicleItems?.vehicles {
                    if vehicles.isEmpty {
                        emptyState
                    } else {
                        // Scrollable list with top padding to avoid overlap with floating search
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(vehicles) { vehicle in
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
                            .padding(.top, searchBarHeight + 16)
                        }
                        .refreshable {
                            await vm.fetchVehicles()
                        }
                    }
                } else if vm.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = vm.error {
                    ContentUnavailableView("로드 실패", systemImage: "exclamationmark.triangle", description: Text(error))
                } else {
                    emptyState
                }
            }

            SearchBarButton(title: "차량 검색") {
                showingSearchView = true
            }
            .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .fullScreenCover(isPresented: $showingSearchView) {
                // 전체 화면으로 표시
                CarSearchView()
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // 데이터가 없을 때만 로드
            if vm.vehicleItems == nil && !vm.isLoading {
                Task {
                    await vm.fetchVehicles()
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            LottieView(animation: .named("empty_list"))
                .playing(loopMode: .loop)
                .frame(width: 200, height: 200)
            
            Text("판매 중인 차량이 없습니다")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("새로운 차량이 등록되면 여기에 표시됩니다")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, searchBarHeight + 100)
    }
}

#Preview { BuyCarView() }
