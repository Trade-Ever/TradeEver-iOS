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
    }
    
    // MARK: - 차량 리스트
    @ViewBuilder
    private var vehiclesList: some View {
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
            // 검색 결과 리스트
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(Array(viewModel.vehicles.enumerated()), id: \.element.id) { index, vehicle in
                        NavigationLink {
                            CarDetailScreen(vehicleId: Int(vehicle.id))
                        } label: {
                            CarListItemView(vehicle: vehicle)
                        }
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
                        .fill(isSelected ? Color.blue : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.3), lineWidth: isSelected ? 0 : 1)
                )
        }
    }
}

#Preview {
    NavigationView {
        CarSearchResultsView(searchModel: CarSearchModel())
    }
}
