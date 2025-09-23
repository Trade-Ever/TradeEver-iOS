import SwiftUI

struct CarSearchView: View {
    @StateObject private var viewModel = CarSearchViewModel()
    @Environment(\.dismiss) private var dismiss
    
    // CarSearch 객체로 통합 관리
    @State private var carSearch = CarSearchModel()
    @StateObject private var carFilter = CarFilterModel()
    
    // UI 상태들
    @State private var showCarFilterFlowSheet: Bool = false
    @State private var showYearFilterSheet: Bool = false
    @State private var showMileageFilterSheet: Bool = false
    @State private var showPriceFilterSheet: Bool = false
    @State private var showCarTypeSheet: Bool = false
    
    // 검색 결과 페이지 이동용 상태 추가
    @State private var showSearchResults: Bool = false
    @State private var searchResultModel: CarSearchModel?
    
    // 슬라이더 상태들
    @State private var yearRange: ClosedRange<Double> = 1998...2025
    @State private var mileageRange: ClosedRange<Double> = 0...30
    @State private var priceRange: ClosedRange<Double> = 1...30
    @State private var selectedCarType: String?
    
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 검색 바 영역
                SearchBarView(
                    searchText: $viewModel.searchText,
                    onClose: {
                        dismiss()
                    }
                )
                
                // 컨텐츠 영역
                ScrollView {
                    VStack(spacing: 8) {
                        // 최근 검색
                        RecentSearchView(
                            recentSearches: viewModel.recentSearches,
                            onSearchTap: { term in
                                viewModel.searchText = term
                            },
                            onRemove: { search in
                                Task {
                                    await viewModel.removeRecentSearch(search)
                                }
                            }
                        )
                        .padding(.bottom, 12)
                        
                        // 구분선
                        Divider()
                            .background(Color(UIColor.separator))
                        
                        VStack(spacing: 0) {
                            FilterRowView(
                                title: "제조사 • 모델",
                                value: formatManufacturerText(),
                                action: {
                                    showCarFilterFlowSheet = true
                                }
                            )
                            
                            Divider()
                                .padding(.horizontal, 20)
                                .foregroundStyle(Color.grey100)
                            
                            FilterRowView(
                                title: "연식",
                                value: formatYearText(),
                                action: {
                                    showYearFilterSheet = true
                                }
                            )
                            
                            Divider()
                                .padding(.horizontal, 20)
                            
                            FilterRowView(
                                title: "주행거리",
                                value: formatMileageText(),
                                action: {
                                    showMileageFilterSheet = true
                                }
                            )
                            
                            Divider()
                                .padding(.horizontal, 20)
                            
                            FilterRowView(
                                title: "가격",
                                value: formatPriceText(),
                                action: {
                                    showPriceFilterSheet = true
                                }
                            )
                            
                            Divider()
                                .padding(.horizontal, 20)
                            
                            FilterRowView(
                                title: "차종",
                                value: carSearch.vehicleType ?? "",
                                action: {
                                    showCarTypeSheet = true
                                }
                            )
                        }
                    }
                    
                    Spacer()
                    
                    BottomSheetButtons(
                        title: "매물보기",
                        onConfirm: {
                            performSearch()
                        },
                        onReset: {
                            resetFilters()
                        }
                    )
                }
            }
            .navigationBarHidden(true)
            .background(Color(UIColor.systemBackground))
            .task {
                await viewModel.fetchRecentSearches()
            }
            .fullScreenCover(isPresented: $showSearchResults) {
                if let searchModel = searchResultModel {
                    CarSearchResultsView(searchModel: searchModel)
                }
                
            }
            // 차량 필터 플로우 시트
            .fullScreenCover(isPresented: $showCarFilterFlowSheet) {
                CarFilterFlowView(
                    isPresented: $showCarFilterFlowSheet,
                    filter: carFilter,
                    includeYear: false,
                    onComplete: { filter in
                        handleCarFilterComplete(filter)
                    }
                )
            }
            // 연식 필터 시트
            .sheet(isPresented: $showYearFilterSheet) {
                YearFilterBottomSheet(
                    isPresented: $showYearFilterSheet,
                    selectedYearRange: $yearRange
                ) {
                    updateYearFilter()
                }
                .presentationDetents([.fraction(0.45)])
            }
            // 주행거리 필터 시트
            .sheet(isPresented: $showMileageFilterSheet) {
                MileageFilterBottomSheet(
                    isPresented: $showMileageFilterSheet,
                    selectedMileageRange: $mileageRange
                ) {
                    updateMileageFilter()
                }
                .presentationDetents([.fraction(0.45)])
            }
            // 가격 필터 시트
            .sheet(isPresented: $showPriceFilterSheet) {
                PriceFilterBottomSheet(
                    isPresented: $showPriceFilterSheet,
                    selectedPriceRange: $priceRange
                ) {
                    updatePriceFilter()
                }
                .presentationDetents([.fraction(0.45)])
            }
            // 차종 선택 시트
            .sheet(isPresented: $showCarTypeSheet) {
                CarTypeBottomSheet(
                    isPresented: $showCarTypeSheet,
                    selectedCarType: $selectedCarType
                ) {
                    updateCarTypeFilter()
                }
                .presentationDetents([.fraction(0.45)])
            }
        }
    }
    
    // MARK: - 포맷팅 함수들
    private func formatManufacturerText() -> String {
        var components: [String] = []
        
        if let manufacturer = carSearch.manufacturer {
            components.append(manufacturer)
        }
        if let carName = carSearch.carName {
            components.append(carName)
        }
        if let carModel = carSearch.carModel {
            components.append(carModel)
        }
        
        return components.joined(separator: " ")
    }
    
    private func formatYearText() -> String {
        guard let yearStart = carSearch.yearStart,
              let yearEnd = carSearch.yearEnd else {
            return ""
        }
        return "\(yearStart)년 ~ \(yearEnd)년"
    }
    
    private func formatMileageText() -> String {
        guard let mileageStart = carSearch.mileageStart,
              let mileageEnd = carSearch.mileageEnd else {
            return ""
        }
        return "\(mileageStart)만km ~ \(mileageEnd)만km"
    }
    
    private func formatPriceText() -> String {
        guard let priceStart = carSearch.priceStart,
              let priceEnd = carSearch.priceEnd else {
            return ""
        }
        return "\(Formatters.priceToEokFormat(Double(priceStart))) ~ \(Formatters.priceToEokFormat(Double(priceEnd)))"
    }
    
    // MARK: - 업데이트 함수들
    private func handleCarFilterComplete(_ filter: CarFilterModel) {
        showCarFilterFlowSheet = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            carSearch.manufacturer = filter.manufacturer
            carSearch.carName = filter.carName
            carSearch.carModel = filter.modelName
        }
    }
    
    private func updateYearFilter() {
        carSearch.yearStart = Int(yearRange.lowerBound)
        carSearch.yearEnd = Int(yearRange.upperBound)
    }
    
    private func updateMileageFilter() {
        carSearch.mileageStart = Int(mileageRange.lowerBound)
        carSearch.mileageEnd = Int(mileageRange.upperBound)
    }
    
    private func updatePriceFilter() {
        carSearch.priceStart = Int(priceRange.lowerBound)
        carSearch.priceEnd = Int(priceRange.upperBound)
    }
    
    private func updateCarTypeFilter() {
        carSearch.vehicleType = selectedCarType
    }
    
    // MARK: - 액션 함수들
    private func performSearch() {
        // 키워드도 포함
        carSearch.keyword = viewModel.searchText.isEmpty ? nil : viewModel.searchText
        
        // 검색 모델을 복사해서 결과 페이지로 전달
        searchResultModel = carSearch
        
        // 실제 검색 API 호출
        Task {
            await viewModel.fetchFilteredCars(with: carSearch)
            // Argument passed to call that takes no arguments
            DispatchQueue.main.async {
                showSearchResults = true
            }
        }
    }
    
    private func resetFilters() {
        carSearch = CarSearchModel()
        selectedCarType = nil
        yearRange = 1998...2025
        mileageRange = 0...30
        priceRange = 1...30
    }
}
