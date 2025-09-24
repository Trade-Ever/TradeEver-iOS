import SwiftUI

import SwiftUI

struct CarSearchResultsView: View {
    @StateObject private var viewModel = CarSearchViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @Binding var searchModel: CarSearchModel

    // 필터 시트 상태값
    @State private var showYearFilterSheet: Bool = false
    @State private var showMileageFilterSheet: Bool = false
    @State private var showPriceFilterSheet: Bool = false
    @State private var showCarTypeSheet: Bool = false
    
    @State private var selectedSortOption: String = "최신순"
    @State private var selectedVehicleId: Int? // 선택된 차량 ID
    
    // 로컬 상태 (결과에서 수정할 수 있도록)
    @State private var yearRange: ClosedRange<Double> = 1998...2025
    @State private var mileageRange: ClosedRange<Double> = 0...30
    @State private var priceRange: ClosedRange<Double> = 1...30
    @State private var selectedCarType: String?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 상단 네비게이션
                topNavigationBar
                
                // 필터 버튼들
                filterButtonsRow
                
                // 차량 리스트
                vehiclesList
            }
            .navigationBarHidden(true)
            .navigationDestination(item: $selectedVehicleId) { vehicleId in
                CarDetailScreen(vehicleId: vehicleId)
            }
            .task {
                let modelToSend = prepareRequestModel(from: searchModel)
                await viewModel.fetchFilteredCars(with: modelToSend)
                
                // 초기값 동기화
                syncFilters()
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
    
    // MARK: - 초기값 동기화
    private func syncFilters() {
        if let start = searchModel.yearStart, let end = searchModel.yearEnd {
            yearRange = Double(start)...Double(end)
        }
        if let start = searchModel.mileageStart, let end = searchModel.mileageEnd {
            mileageRange = Double(start)...Double(end)
        }
        if let start = searchModel.priceStart, let end = searchModel.priceEnd {
            priceRange = Double(start)...Double(end)
        }
        if let type = searchModel.vehicleType {
            selectedCarType = type
        }
    }
    
    // MARK: - 상단 네비게이션 바
    private var topNavigationBar: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                
                Button(action: {
                    dismiss()
                }) {
                    Text("나가기")
                        .foregroundStyle(Color.purple400)
                }
                .padding(.top)
                .padding(.trailing)
            }
            HStack {
                Text("검색결과")
                    .font(.system(size: 24, weight: .bold))
                    .padding(.leading, 12)
                
                Spacer()
            }
        }
        .frame(height: 44)
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
                        // 경매 아이템인지 확인하여 적절한 뷰 사용
                        if vehicle.isAuction == "Y" {
                            // Vehicle을 VehicleAPIItem으로 변환
                            let vehicleAPIItem = VehicleAPIItem(
                                id: Int64(vehicle.id),
                                carName: vehicle.carName,
                                carNumber: vehicle.carNumber,
                                manufacturer: vehicle.manufacturer,
                                model: vehicle.model,
                                year_value: vehicle.yearValue,
                                mileage: vehicle.mileage,
                                transmission: vehicle.transmission,
                                vehicleStatus: vehicle.vehicleStatus,
                                fuelType: vehicle.fuelType,
                                price: vehicle.price,
                                isAuction: vehicle.isAuction,
                                representativePhotoUrl: vehicle.representativePhotoUrl,
                                locationAddress: nil, // Vehicle에는 없음
                                favoriteCount: vehicle.favoriteCount,
                                createdAt: vehicle.createdAt,
                                vehicleTypeName: vehicle.vehicleTypeName,
                                mainOptions: vehicle.mainOptions,
                                totalOptionsCount: vehicle.totalOptionsCount,
                                auctionId: vehicle.auctionId != nil ? Int64(vehicle.auctionId!) : nil,
                                startPrice: nil, // Vehicle에는 없음
                                currentPrice: nil, // Vehicle에는 없음
                                startAt: nil, // Vehicle에는 없음
                                endAt: nil, // Vehicle에는 없음
                                auctionStatus: nil, // Vehicle에는 없음
                                bidCount: nil, // Vehicle에는 없음
                                isFavorite: vehicle.isFavorite
                            )
                            
                            AuctionCarListItemViewWithFirebase(
                                vehicle: vehicleAPIItem
                            )
                            .onTapGesture {
                                selectedVehicleId = Int(vehicle.id)
                                print("경매 차량 선택됨: \(vehicle.id)")
                            }
                            .onAppear {
                                // 무한 스크롤 - index 기반으로 수정
                                if index == viewModel.vehicles.count - 1 && viewModel.hasMoreData {
                                    Task {
                                        let modelToSend = prepareRequestModel(from: searchModel)
                                        await viewModel.fetchFilteredCars(with: modelToSend, isLoadMore: true)
                                    }
                                }
                            }
                        } else {
                            CarListItemView(vehicle: vehicle)
                                .onTapGesture {
                                    selectedVehicleId = Int(vehicle.id)
                                    print("일반 차량 선택됨: \(vehicle.id)")
                                }
                                .onAppear {
                                    // 무한 스크롤 - index 기반으로 수정
                                    if index == viewModel.vehicles.count - 1 && viewModel.hasMoreData {
                                        Task {
                                            let modelToSend = prepareRequestModel(from: searchModel)
                                            await viewModel.fetchFilteredCars(with: modelToSend, isLoadMore: true)
                                        }
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
                let modelToSend = prepareRequestModel(from: searchModel)
                await viewModel.fetchFilteredCars(with: modelToSend)
            }
        }
    }
    
    // MARK: - 필터 버튼들
    private var filterButtonsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // 연식 버튼
                FilterChipButton(
                    title: formatYearText(),
                    isSelected: searchModel.yearStart != nil
                ) {
                    showYearFilterSheet = true
                }
                
                // 차종 버튼
                FilterChipButton(
                    title: selectedCarType ?? "차종",
                    isSelected: selectedCarType != nil
                ) {
                    showCarTypeSheet = true
                }
                
                // 주행거리 버튼
                FilterChipButton(
                    title: formatMileageText(),
                    isSelected: searchModel.mileageStart != nil
                ) {
                    showMileageFilterSheet = true
                }
                
                // 가격 버튼
                FilterChipButton(
                    title: formatPriceText(),
                    isSelected: searchModel.priceStart != nil
                ) {
                    showPriceFilterSheet = true
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 24)
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
    
    // MARK: - 필터 칩 버튼
    struct FilterChipButton: View {
        let title: String
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                Text(title)
                    .lineLimit(1) // 한 줄 고정
                    .truncationMode(.tail) // ... 처리
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isSelected ? Color.purple300 : Color.clear)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.3), lineWidth: isSelected ? 0 : 1)
                    )
            }
        }
    }
    
    // MARK: - 포맷팅
    private func formatYearText() -> String {
        if let start = searchModel.yearStart, let end = searchModel.yearEnd {
            return "\(start)년~\(end)년"
        }
        return "연식"
    }
    
    private func formatMileageText() -> String {
        if let start = searchModel.mileageStart, let end = searchModel.mileageEnd {
            return "\(start)만~\(end)만 km"
        }
        return "주행거리"
    }
    
    private func formatPriceText() -> String {
        if let start = searchModel.priceStart, let end = searchModel.priceEnd {
            return "\(Formatters.priceToEokFormat(Double(start)))~\(Formatters.priceToEokFormat(Double(end)))"
        }
        return "가격"
    }
    
    private func updateYearFilter() {
        searchModel.yearStart = Int(yearRange.lowerBound)
        searchModel.yearEnd = Int(yearRange.upperBound)
        fetchDataWithCurrentFilters()

    }
    
    private func updateMileageFilter() {
        searchModel.mileageStart = Int(mileageRange.lowerBound)
        searchModel.mileageEnd = Int(mileageRange.upperBound)
        fetchDataWithCurrentFilters()
    }
    
    private func updatePriceFilter() {
        searchModel.priceStart = Int(priceRange.lowerBound)
        searchModel.priceEnd = Int(priceRange.upperBound)
        fetchDataWithCurrentFilters()

    }
    
    private func updateCarTypeFilter() {
        searchModel.vehicleType = selectedCarType
        fetchDataWithCurrentFilters()

    }
    
    private func fetchDataWithCurrentFilters() {
        Task {
            var modelToSend = searchModel
            modelToSend.vehicleType = Formatters.mapVehicleType(searchModel.vehicleType)
            modelToSend.mileageStart = Formatters.toTenThousand(from: searchModel.mileageStart) // 만원단위
            modelToSend.mileageEnd = Formatters.toTenThousand(from: searchModel.mileageEnd) // 만원단위
            modelToSend.priceStart = Formatters.toTenMillion(from: searchModel.priceStart) // 천만원 단위
            modelToSend.priceEnd = Formatters.toTenMillion(from: searchModel.priceEnd) // 천만원 단위
            await viewModel.fetchFilteredCars(with: modelToSend)
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
}

// MARK: - Firebase 연동 경매 아이템 뷰
struct AuctionCarListItemViewWithFirebase: View {
    let vehicle: VehicleAPIItem
    
    @State private var liveAuction: AuctionLive? = nil
    @State private var auctionHandle: UInt? = nil
    
    var body: some View {
        AuctionCarListItemView(vehicle: vehicle, live: liveAuction)
            .onAppear {
                subscribeToAuction()
            }
            .onDisappear {
                unsubscribeFromAuction()
            }
    }
    
    // MARK: - Firebase Methods
    private func subscribeToAuction() {
        guard vehicle.isAuction == "Y" else { return }
        
        // vehicleId로 Firebase에서 경매 데이터 구독
        let handle = FirebaseAuctionService.shared.observeAuctionByVehicleIdContinuous(vehicleId: Int(vehicle.id)) { live in
            Task { @MainActor in
                self.liveAuction = live
            }
        }
        auctionHandle = handle
    }
    
    private func unsubscribeFromAuction() {
        guard let handle = auctionHandle else { return }
        
        // Firebase 구독 해제
        FirebaseAuctionService.shared.removeObserver(auctionId: Int(vehicle.id), handle: handle)
        auctionHandle = nil
    }
}


