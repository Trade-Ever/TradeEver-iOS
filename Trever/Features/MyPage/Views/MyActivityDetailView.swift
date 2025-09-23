import SwiftUI

struct MyActivityDetailView: View {
    @State private var selectedTab: ActivityTab = .recent
    
    init(initialTab: ActivityTab = .recent) {
        self._selectedTab = State(initialValue: initialTab)
    }
    
    enum ActivityTab: String, CaseIterable {
        case recent = "최근"
        case liked = "찜"
        
        var title: String {
            return self.rawValue
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 탭 선택기
            tabSelector
            
            // 컨텐츠
            TabView(selection: $selectedTab) {
                RecentViewsView()
                    .tag(ActivityTab.recent)
                
                FavoritesView()
                    .tag(ActivityTab.liked)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .navigationTitle("나의 활동")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(ActivityTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 8) {
                        Text(tab.title)
                            .font(.headline)
                            .foregroundColor(selectedTab == tab ? .primary : .secondary)
                        
                        Rectangle()
                            .fill(selectedTab == tab ? Color.purple400 : Color.clear)
                            .frame(height: 2)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
}

// MARK: - 최근 본 차량 뷰
struct RecentCarsView: View {
    @StateObject private var viewModel = RecentCarsViewModel()
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if viewModel.isLoading {
                    ProgressView("로딩 중...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 100)
                } else if viewModel.cars.isEmpty {
                    emptyState
                } else {
                    ForEach(viewModel.cars) { car in
                        NavigationLink(destination: CarDetailScreen(vehicleId: Int(car.id))) {
                            CarListItemView(apiModel: car)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
        .refreshable {
            await viewModel.loadRecentCars()
        }
        .onAppear {
            Task {
                await viewModel.loadRecentCars()
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("최근 본 차량이 없습니다")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("차량을 둘러보시면 여기에 표시됩니다")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
}

// MARK: - 찜한 차량 뷰
struct LikedCarsView: View {
    @StateObject private var viewModel = LikedCarsViewModel()
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if viewModel.isLoading {
                    ProgressView("로딩 중...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 100)
                } else if viewModel.cars.isEmpty {
                    emptyState
                } else {
                    ForEach(viewModel.cars) { car in
                        NavigationLink(destination: CarDetailScreen(vehicleId: Int(car.id))) {
                            CarListItemView(apiModel: car)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
        .refreshable {
            await viewModel.loadLikedCars()
        }
        .onAppear {
            Task {
                await viewModel.loadLikedCars()
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("찜한 차량이 없습니다")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("마음에 드는 차량을 찜해보세요")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
}

// MARK: - ViewModels
@MainActor
class RecentCarsViewModel: ObservableObject {
    @Published var cars: [VehicleAPIItem] = []
    @Published var isLoading = false
    
    func loadRecentCars() async {
        isLoading = true
        // TODO: 실제 API 호출로 최근 본 차량 데이터 로드
        // 임시 데이터
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1초 대기
        cars = []
        isLoading = false
    }
}

@MainActor
class LikedCarsViewModel: ObservableObject {
    @Published var cars: [VehicleAPIItem] = []
    @Published var isLoading = false
    
    func loadLikedCars() async {
        isLoading = true
        // TODO: 실제 API 호출로 찜한 차량 데이터 로드
        // 임시 데이터
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1초 대기
        cars = []
        isLoading = false
    }
}

#Preview {
    NavigationView {
        MyActivityDetailView()
    }
}
