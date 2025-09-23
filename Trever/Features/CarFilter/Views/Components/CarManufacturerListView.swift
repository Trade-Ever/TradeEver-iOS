//
//  ManufacturerListView.swift
//  Trever
//
//  Created by OhChangEun on 9/19/25.
//

//
//  ManufacturerListView.swift
//  Trever
//
//  Created by OhChangEun on 9/19/25.
//

import SwiftUI

// 제조사 목록
struct CarManufacturerListView: View {
    @ObservedObject var filter: CarFilterModel
    @StateObject private var viewModel = ManufacturerViewModel()

    @State private var navigateToNext = false    
    var includeYear: Bool = true                  // 연도까지 필터링할것인지
    let onComplete: ((CarFilterModel) -> Void)?   // 완료 콜백
    
    //    // 샘플 데이터
    //    let domesticCars: [(String, String, Int, Bool)] = [
    //        ("hyundai_logo", "현대", 44661, true),
    //        ("hyundai_logo", "제네시스", 11696, false),
    //        ("hyundai_logo", "기아", 11696, false),
    //        ("hyundai_logo", "쉐보레(GM 대우)", 11696, false),
    //        ("hyundai_logo", "르노코리아(삼성)", 11696, false)
    //    ]
    //
    //    let importedCars: [(String, String, Int, Bool)] = [
    //        ("hyundai_logo", "BMW", 11696, false),
    //        ("hyundai_logo", "벤츠", 11696, false),
    //        ("hyundai_logo", "아우디", 11696, false),
    //        ("hyundai_logo", "포르쉐", 11696, false),
    //        ("hyundai_logo", "미니", 11696, false)
    //    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .center, spacing: 12) {

                    if viewModel.isLoading {
                        ProgressView().padding()
                    } else if let error = viewModel.errorMessage {
                        Text("오류: \(error)").foregroundColor(.errorRed)
                    } else {
                        Text("제조사")
                            .font(.title3)
                            .bold()
                            .padding(.top, 32)
                            .padding(.bottom, 28)
                        
                        CarFilterSection(
                            title: "국산차",
                            data: viewModel.domesticCars.map { (nil, $0.manufacturer, $0.count, false) },
                            showDivider: true,
                            onRowTap: { selectedManufacturer in
                                filter.category = "국산"
                                filter.manufacturer = selectedManufacturer
                                navigateToNext = true // 다음 단계(차명)로
                            }
                        )
                        
                        CarFilterSection(
                            title: "수입차",
                            data: viewModel.importedCars.map { (nil, $0.manufacturer, $0.count, false) },
                            onRowTap: { selectedManufacturer in
                                filter.category = "수입"
                                filter.manufacturer = selectedManufacturer
                                navigateToNext = true
                            }
                        )
                    }
                    Spacer(minLength: 40) // 하단 자리 확보
                }
                .task {
                    // 년도가 필요하면 > 차량 등록시 필요한 필터 > 숫자 등장 x
                    // 년도가 필요없으면 > 차량 검색시 필요한 필터 > 숫자 등장 o
                    await viewModel.fetchCarManufacturers(includeYear: includeYear)
                }
            }
            .navigationDestination(isPresented: $navigateToNext) {
                CarNameListView(filter: filter, includeYear: includeYear, onComplete: onComplete) // 완료 콜백 전달
            }
        }
    }
}
