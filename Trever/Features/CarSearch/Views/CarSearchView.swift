//
//  CarSearchView.swift
//  Trever
//
//  Created by OhChangEun on 9/22/25.
//

import SwiftUI


struct CarSearchView: View {
    @StateObject private var viewModel = CarSearchViewModel()
    @Environment(\.dismiss) private var dismiss
    
    // 차량 선택 플로우 시트
    @State private var showCarFilterFlowSheet: Bool = false // 제조사 플로우 시트
    @State private var showYearFilterSheet: Bool = false    // 연식 범위 시트
    @State private var showMileageFilterSheet: Bool = false // 주행거리 범위 시트
    @State private var showPriceFilterSheet: Bool = false   // 가격 범위 시트
    @State private var showCarTypeSheet: Bool = false       // 차량 타입 선택 시트
    
    @State private var yearRange: ClosedRange<Double> = 1998...2025
    @State private var mileageRange: ClosedRange<Double> = 0...30    // 0 ~ 30억
    @State private var priceRange: ClosedRange<Double> = 1...30      // 천만원 ~ 3억
    
    @State private var selectedCarType: String?  // 선택된 차량 타입

    @StateObject private var carFilter = CarFilterModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 검색 바 영역
                SearchBarView(
                    searchText: $viewModel.searchText,
                    onClose: {
                        dismiss() // 창 닫기
                    }
                )
                
                // 컨텐츠 영역
                ScrollView {
                    VStack(spacing: 8) {
                        // 최근 검색
                        if !viewModel.recentSearches.isEmpty {
                            RecentSearchView(
                                recentSearches: viewModel.recentSearches,
                                onSearchTap: { term in
                                    viewModel.searchText = term
                                },
                                onRemove: { search in
                                    viewModel.removeRecentSearch(search)
                                }
                            )
                            .padding(.bottom, 20)
                        }
                        
                        // 여백을 추가하여 필터가 하단에 고정되도록 함
                        Spacer(minLength: 100)
                    }
                }
                
                // 고정된 필터 영역
                VStack(spacing: 0) {
                    // 구분선 추가
                    Divider()
                        .background(Color(UIColor.separator))
                    
                    VStack(spacing: 0) {
                        FilterRowView(
                            title: "제조사 • 모델",
                            value: viewModel.filters.manufacturer,
                            action: {
                                showCarFilterFlowSheet = true
                            }
                        )
                        
                        Divider()
                            .padding(.horizontal, 20)
                            .foregroundStyle(Color.grey100)
                        
                        FilterRowView(
                            title: "연식",
                            value: viewModel.filters.year,
                            action: {
                                showYearFilterSheet = true
                            }
                        )
                        
                        Divider()
                            .padding(.horizontal, 20)
                        
                        FilterRowView(
                            title: "주행거리",
                            value: viewModel.filters.mileage,
                            action: {
                                showMileageFilterSheet = true
                            }
                        )
                        
                        Divider()
                            .padding(.horizontal, 20)
                        
                        FilterRowView(
                            title: "가격",
                            value: viewModel.filters.price,
                            action: {
                                showPriceFilterSheet = true
                            }
                        )
                        
                        Divider()
                            .padding(.horizontal, 20)
                        
                        FilterRowView(
                            title: "차종",
                            value: viewModel.filters.vehicleType,
                            action: {
                                showCarTypeSheet = true
                            }
                        )
                    }
                    .background(Color(UIColor.systemBackground))
                    
                    BottomSheetButtons(
                        title : "매물보기",
                        onConfirm: { viewModel.performSearch() },
                        onReset: {viewModel.resetFilters()}
                    )
                }
            }
            .navigationBarHidden(true)
            .background(Color(UIColor.systemBackground))
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
            .sheet(isPresented: $showYearFilterSheet, onDismiss: {
                updateYearFilterComplete()
            }) {
                YearFilterBottomSheet(
                    isPresented: $showYearFilterSheet,
                    selectedYearRange: $yearRange
                )
                .presentationDetents([.fraction(0.45)])
            }
            // 주행거리 필터 시트
            .sheet(isPresented: $showMileageFilterSheet, onDismiss: {
                updateMileageFilterComplete()
            }) {
                MileageFilterBottomSheet(
                    isPresented: $showMileageFilterSheet,
                    selectedMileageRange: $mileageRange
                )
                .presentationDetents([.fraction(0.45)])
            }
            // 가격 필터 시트
            .sheet(isPresented: $showPriceFilterSheet, onDismiss: {
                updatePriceFilterComplete()
            }) {
                PriceFilterBottomSheet(
                    isPresented: $showPriceFilterSheet,
                    selectedPriceRange: $priceRange
                )
                .presentationDetents([.fraction(0.45)])
            }
            // 차종 선택 시트
            .sheet(isPresented: $showCarTypeSheet, onDismiss: {
                updatePriceFilterComplete()
            }) {
                CarTypeBottomSheet(
                    isPresented: $showCarTypeSheet,
                    selectedCarType: $selectedCarType // 단일 선택
                )
                .presentationDetents([.fraction(0.45)])
            }
        }
    }
    
    // 차량 선택 완료 처리
    private func handleCarFilterComplete(_ filter: CarFilterModel) {
        // 시트 닫기
        showCarFilterFlowSheet = false
        
        // 선택된 차량 정보를 뷰모델 필터에 반영
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // 제조사 •모델 조합해서 표시
            var filteredCarInfoText = ""
            if let manufacturer = filter.manufacturer {
                filteredCarInfoText += manufacturer
            }
            if let modelName = filter.modelName {
                filteredCarInfoText += filteredCarInfoText.isEmpty ? modelName : " \(modelName)"
            }

            viewModel.filters.manufacturer = filteredCarInfoText
        }
    }
    
    // 차량 연식 완료처리
    private func updateYearFilterComplete() {
        let lower = Int(yearRange.lowerBound)
        let upper = Int(yearRange.upperBound)
        viewModel.filters.year = "\(lower)년 ~ \(upper)년"
    }
    
    // 차량 연식 완료처리
    private func updateMileageFilterComplete() {
        let lower = Int(mileageRange.lowerBound)
        let upper = Int(mileageRange.upperBound)
        viewModel.filters.mileage = "\(lower)만km ~ \(upper)만km"
    }
    
    // 차량 가격 완료처리
    private func updatePriceFilterComplete() {
        let lower = priceRange.lowerBound
        let upper = priceRange.upperBound
        
        viewModel.filters.price = "\(Formatters.priceToEokFormat(lower)) ~ \(Formatters.priceToEokFormat(upper))"
    }
    
    // 차량 가격 완료처리
    private func updateCarTypeComplete() {
        if let carType = selectedCarType {
            viewModel.filters.vehicleType = carType
        }
    }
}
