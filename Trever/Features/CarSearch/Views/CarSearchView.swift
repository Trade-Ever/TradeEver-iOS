import SwiftUI

struct CarSearchView: View {
    @StateObject private var viewModel = CarSearchViewModel()
    @Environment(\.dismiss) private var dismiss
    
    // CarSearch 객체로 통합 관리
    @State private var searchModel = CarSearchModel()
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
                                title: "차종",
                                value: searchModel.vehicleType ?? "",
                                action: {
                                    showCarTypeSheet = true
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
                    CarSearchResultsView(searchModel: $searchModel)
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
        
        if let manufacturer = searchModel.manufacturer {
            components.append(manufacturer)
        }
        if let carName = searchModel.carName {
            components.append(carName)
        }
        if let carModel = searchModel.carModel {
            components.append(carModel)
        }
        
        return components.joined(separator: " ")
    }
    
    private func formatYearText() -> String {
        guard let yearStart = searchModel.yearStart,
              let yearEnd = searchModel.yearEnd else {
            return ""
        }
        return "\(yearStart)년 ~ \(yearEnd)년"
    }
    
    private func formatMileageText() -> String {
        guard let mileageStart = searchModel.mileageStart,
              let mileageEnd = searchModel.mileageEnd else {
            return ""
        }
        return "\(mileageStart)만km ~ \(mileageEnd)만km"
    }
    
    private func formatPriceText() -> String {
        guard let priceStart = searchModel.priceStart,
              let priceEnd = searchModel.priceEnd else {
            return ""
        }
        return "\(Formatters.priceToEokFormat(Double(priceStart))) ~ \(Formatters.priceToEokFormat(Double(priceEnd)))"
    }
    
    // MARK: - 업데이트 함수들
    func handleCarFilterComplete(_ filter: CarFilterModel) {
        showCarFilterFlowSheet = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            searchModel.manufacturer = filter.manufacturer
            searchModel.carName = filter.carName
            searchModel.carModel = filter.modelName
        }
    }
    
    func updateYearFilter() {
        searchModel.yearStart = Int(yearRange.lowerBound)
        searchModel.yearEnd = Int(yearRange.upperBound)
    }
    
    func updateMileageFilter() {
        searchModel.mileageStart = Int(mileageRange.lowerBound)
        searchModel.mileageEnd = Int(mileageRange.upperBound)
    }
    
    func updatePriceFilter() {
        searchModel.priceStart = Int(priceRange.lowerBound)
        searchModel.priceEnd = Int(priceRange.upperBound)
    }
    
    func updateCarTypeFilter() {
        searchModel.vehicleType = selectedCarType
    }
    
    // MARK: - 액션 함수들
    private func performSearch() {
        // 키워드도 포함
        searchModel.keyword = viewModel.searchText.isEmpty ? nil : viewModel.searchText
        
        // 실제 검색 API 호출
        Task {
            let modelToSend = prepareRequestModel(from: searchModel)
            await viewModel.fetchFilteredCars(with: modelToSend)
            
            DispatchQueue.main.async {
                // 검색 모델을 복사해서 결과 페이지로 전달
                searchResultModel = searchModel
                showSearchResults = true
            }
        }
    }
    
    private func prepareRequestModel(from carSearch: CarSearchModel) -> CarSearchModel {
        var model = carSearch
        model.vehicleType = Formatters.mapVehicleType(carSearch.vehicleType)
        model.mileageStart = Formatters.toTenThousand(from: carSearch.mileageStart)
        model.mileageEnd = Formatters.toTenThousand(from: carSearch.mileageEnd)
        model.priceStart = Formatters.toTenMillion(from: carSearch.priceStart)
        model.priceEnd = Formatters.toTenMillion(from: carSearch.priceEnd)
        return model
    }
    
    private func resetFilters() {
        searchModel = CarSearchModel()
        selectedCarType = nil
        yearRange = 1998...2025
        mileageRange = 0...30
        priceRange = 1...30
    }
}
