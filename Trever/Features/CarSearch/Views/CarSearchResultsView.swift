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
        .background(Color(UIColor.systemBackground))
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
        .background(Color(UIColor.systemBackground))
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
                // 검색 결과 리스트 - 🔧 수정된 부분
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
        .background(Color(UIColor.systemBackground))
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
    @State private var isFavorite: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // 차량 이미지
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: vehicle.representativePhotoUrl ?? "")) { phase in
                    switch phase {
                    case .empty:
                        // 로딩 중 placeholder
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                            .aspectRatio(16/10, contentMode: .fill)
                            .overlay(
                                Image(systemName: "car.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                            )
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(16/10, contentMode: .fill)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    case .failure(_):
                        // 실패 시 fallback
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                            .aspectRatio(16/10, contentMode: .fill)
                            .overlay(
                                Image(systemName: "car.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
                
                // 찜하기 버튼 (그대로 유지)
                Button(action: {
                    isFavorite.toggle()
                }) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 20))
                        .foregroundColor(isFavorite ? .red : .white)
                        .background(
                            Circle()
                                .fill(Color.black.opacity(0.3))
                                .frame(width: 36, height: 36)
                        )
                }
                .padding(.top, 12)
                .padding(.trailing, 12)
            }
            // 차량 정보
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(vehicle.model ?? "차량명")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                
                HStack(spacing: 4) {
                    Text("\(vehicle.yearValue ?? 2024)년식")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Text("\(Int(vehicle.mileage ?? 0).formattedWithCommas())km")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Text(vehicle.fuelType ?? "연료타입")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                
                HStack {
                    Text("\(Formatters.priceText(won: vehicle.price ?? 0))")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        )
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
