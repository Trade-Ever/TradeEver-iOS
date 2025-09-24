import SwiftUI

struct CarSearchResultsView: View {
    @StateObject private var viewModel = CarSearchViewModel()
    @Environment(\.dismiss) private var dismiss
    
    let searchModel: CarSearchModel
    
    @State private var showSortSheet: Bool = false
    @State private var selectedSortOption: String = "최신순"
    
    var body: some View {
        VStack(spacing: 0) {
            // 상단 네비게이션
            topNavigationBar
            
            // 필터 버튼들
            filterButtonsRow
            
            // 차량 리스트
            vehiclesList
        }
        .navigationBarHidden(true)
        .task {
            await viewModel.fetchFilteredCars(with: searchModel)
        }
        .sheet(isPresented: $showSortSheet) {
            sortBottomSheet
        }
    }
    
    // MARK: - 상단 네비게이션 바
    private var topNavigationBar: some View {
        HStack {
            Text("검색결과")
                .font(.system(size: 20, weight: .semibold))
                .padding(.leading, 8)
                .foregroundStyle(Color.black)
                .padding(.leading)
            
            Spacer()
            
            Button(action: {
                dismiss()
            }) {
                Text("나가기")
                    .foregroundStyle(Color.purple400)
            }
            .padding(.trailing)
        }
        .frame(height: 44)
        //.background(Color(UIColor.systemBackground))
    }
    
    // MARK: - 필터 버튼들
    private var filterButtonsRow: some View {
        HStack(spacing: 8) {
            // 가격 필터 버튼
            FilterChipButton(
                title: "0km ~ 150,000km",
                isSelected: false,
                action: {
                    // 가격 필터 액션
                }
            )
            
            // 주행거리 필터 버튼
            FilterChipButton(
                title: "주행거리",
                isSelected: false,
                action: {
                    // 주행거리 필터 액션
                }
            )
            
            Spacer()
            
            // 정렬 버튼
            Button(action: {
                showSortSheet = true
            }) {
                HStack(spacing: 4) {
                    Text("정렬")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.primary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        //.background(Color(UIColor.systemBackground))
    }
    
    // MARK: - 차량 리스트
    private var vehiclesList: some View {
        Group {
            if viewModel.isSearching {
                // 로딩 상태
                VStack {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("검색 중...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.top, 16)
                    Spacer()
                }
            } else if viewModel.vehicles.isEmpty {
                // 검색 결과 없음
                emptyResultsView
            } else {
                // 검색 결과 리스트 - 수정된 부분
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(viewModel.vehicles.enumerated()), id: \.element.id) { index, vehicle in
                            NavigationLink {
                                CarDetailScreen(vehicleId: Int(vehicle.id))
                            } label: {
                                SearchResultCarCard(vehicle: vehicle)
                            }
                            .buttonStyle(.plain)
                            .onAppear {
                                // 무한 스크롤 - index 기반으로 수정
                                if index == viewModel.vehicles.count - 1 && viewModel.hasMoreData {
                                    Task {
                                        await viewModel.fetchFilteredCars(with: searchModel, isLoadMore: true)
                                    }
                                }
                            }
                        }
                        
                        // 더 많은 데이터 로딩 인디케이터
                        if viewModel.isSearching && !viewModel.vehicles.isEmpty {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .padding()
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
                .refreshable {
                    await viewModel.fetchFilteredCars(with: searchModel)
                }
                //.background(Color(UIColor.systemGroupedBackground))
            }
        }
    }
    
    // MARK: - 빈 결과 뷰
    private var emptyResultsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "car.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("검색 결과가 없습니다")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("다른 검색 조건으로 시도해보세요")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    // MARK: - 정렬 바텀시트
    private var sortBottomSheet: some View {
        VStack(spacing: 0) {
            // 핸들
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 36, height: 4)
                .padding(.top, 12)
                .padding(.bottom, 20)
            
            // 타이틀
            HStack {
                Text("정렬")
                    .font(.system(size: 18, weight: .semibold))
                    .padding(.leading, 20)
                
                Spacer()
            }
            .padding(.bottom, 20)
            
            // 정렬 옵션들
            VStack(spacing: 0) {
                ForEach(["최신순", "가격 낮은순", "가격 높은순", "주행거리 적은순", "연식 최신순"], id: \.self) { option in
                    Button(action: {
                        selectedSortOption = option
                        showSortSheet = false
                        // 정렬 로직 실행
                    }) {
                        HStack {
                            Text(option)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if selectedSortOption == option {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal, 20)
                        .frame(height: 48)
                    }
                }
            }
            
            Spacer()
        }
        .presentationDetents([.height(300)])
    }
}

// MARK: - 필터 칩 버튼
struct FilterChipButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? Color.blue : Color.gray.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.3), lineWidth: isSelected ? 0 : 1)
                )
        }
    }
}

// MARK: - 검색 결과 차량 카드
struct SearchResultCarCard: View {
    let vehicle: Vehicle
    
    // State
    @StateObject private var favoriteManager = FavoriteManager.shared
    @State private var isToggling = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                thumbnail
                    .frame(height: 180)
                    .clipped()
                
                if isAuction { auctionBadge }
                
                HStack { Spacer(); likeButton }
                    .buttonStyle(.plain)
                    .padding(4)
            }
            
            infoSection
                .padding(12)
                .background(Color.white)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 0.5)
        )
        .contentShape(Rectangle())
        .onAppear {
            // 전역 상태에 초기 값 설정 (아직 설정되지 않은 경우에만)
            if favoriteManager.favoriteStates[vehicle.id] == nil {
                favoriteManager.setFavoriteState(vehicleId: vehicle.id, isFavorite: vehicle.isFavorite)
            }
        }
    }
}

// MARK: - Computed Properties
private extension SearchResultCarCard {
    var isAuction: Bool {
        vehicle.isAuction.uppercased() == "Y"
    }
    
    var displayPrice: Int {
        vehicle.price ?? 0
    }
    
    var displayTitle: String {
        if !vehicle.manufacturer.isEmpty && !vehicle.model.isEmpty {
            return "\(vehicle.manufacturer) \(vehicle.model)"
        }
        return vehicle.carName.isEmpty ? "차량" : vehicle.carName
    }
    
    var displayTags: [String] {
        Array(vehicle.mainOptions.prefix(3))
    }
}

// MARK: - Subviews
private extension SearchResultCarCard {
    @ViewBuilder
    var thumbnail: some View {
        if let urlString = vehicle.representativePhotoUrl,
           !urlString.isEmpty,
           let url = URL(string: urlString),
           url.scheme?.hasPrefix("http") == true {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ZStack { Color.secondary.opacity(0.08); ProgressView() }
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure:
                    placeholder
                @unknown default:
                    placeholder
                }
            }
        } else {
            placeholder
        }
    }
    
    var placeholder: some View {
        Rectangle()
            .fill(Color.secondary.opacity(0.15))
            .overlay(
                Image(systemName: "car.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.secondary)
            )
    }
    
    var auctionBadge: some View {
        Text("경매")
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.white)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(
                Capsule().fill(Color(red: 1.0, green: 0.54, blue: 0.54))
            )
            .padding(8)
    }
    
    var likeButton: some View {
        Button {
            toggleFavorite()
        } label: {
            if isToggling {
                ProgressView()
                    .scaleEffect(0.8)
                    .foregroundStyle(.secondary)
            } else {
                let isLiked = favoriteManager.isFavorite(vehicleId: vehicle.id)
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .foregroundStyle(isLiked ? Color.likeRed : .secondary)
                    .font(.system(size: 20, weight: .semibold))
            }
        }
        .padding(8)
        .disabled(isToggling)
    }
    
    var infoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 타이틀과 경매 시간 (필요시)
            HStack(alignment: .center) {
                Text(displayTitle)
                    .font(.headline)
                    .foregroundStyle(Color.primaryText)
                Spacer()
                // 경매 종료 시간은 Vehicle 모델에 없어서 제외
                // 필요하다면 auctionEndTime 프로퍼티 추가 필요
            }
            
            // 연식과 주행거리
            Text("\(Formatters.yearText(vehicle.yearValue)) · \(Formatters.mileageText(km: vehicle.mileage))")
                .foregroundStyle(Color.primaryText.opacity(0.7))
                .font(.subheadline)
            
            // 태그와 가격
            HStack {
                if !displayTags.isEmpty { tagsView }
                Spacer()
                priceRow
            }
        }
    }
    
    var tagsView: some View {
        HStack(spacing: 5) {
            ForEach(displayTags, id: \.self) { tag in
                Text(tag)
                    .font(.caption2)
                    .foregroundStyle(Color.secondaryText.opacity(0.7))
                    .padding(.vertical, 4)
                    .padding(.horizontal, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(Color.gray.opacity(0.2))
                    )
            }
        }
    }
    
    @ViewBuilder
    var priceRow: some View {
        HStack {
            Spacer()
            if isAuction {
                Text("최고 입찰가 ")
                    .foregroundStyle(.black)
                    .font(.subheadline)
            }
            Text(Formatters.priceText(won: displayPrice))
                .foregroundStyle(Color.priceGreen)
                .font(.title2).bold()
        }
    }
}

// MARK: - Actions
private extension SearchResultCarCard {
    func toggleFavorite() {
        guard !isToggling else { return }
        
        isToggling = true
        
        Task {
            let result = await NetworkManager.shared.toggleFavorite(vehicleId: vehicle.id)
            
            await MainActor.run {
                isToggling = false
                if let newFavoriteState = result {
                    // 전역 상태 업데이트
                    favoriteManager.toggleFavorite(vehicleId: vehicle.id, newState: newFavoriteState)
                }
            }
        }
    }
}

// MARK: - Int Extension for formatting
extension Int {
    func formattedWithCommas() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

#Preview {
    NavigationView {
        CarSearchResultsView(searchModel: CarSearchModel())
    }
}
