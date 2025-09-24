import SwiftUI
import Lottie

struct BuyCarView: View {
    @State private var showingSearchView = false
    @ObservedObject private var vm = BuyCarListViewModel.shared
    private let searchBarHeight: CGFloat = 48
    
    var body: some View {
        VStack(spacing: 0) {
            // 상단바
            HStack {
                Image("Trever") // 로고
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 40)
                    .padding(.leading, 16)

                Spacer()
                
                SearchBarButton {
                    showingSearchView = true
                }
                .padding(.trailing, 4)
                .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
                .frame(height: 40)
            }
            .padding(.top, 8)
            .padding(.bottom, 8)
            
            Divider() // 상단바 구분선
            
            // 차량 리스트 / 상태 뷰
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
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showingSearchView) {
            CarSearchView() // 차 검색 뷰 
        }
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
