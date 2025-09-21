//
//  CarModelView.swift
//  Trever
//
//  Created by OhChangEun on 9/20/25.
//

import SwiftUI

// 연식 목록
struct CarYearListView: View {
    @ObservedObject var filter: CarFilterModel
    @StateObject private var viewModel = CarYearViewModel()

    @State private var navigateToNext = false
    let onComplete: ((CarFilterModel) -> Void)? // 콜백 받기

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 12) {
                Text(filter.carName ?? "연식 선택")
                    .font(.title3)
                    .bold()
                    .padding(.bottom, 36)
                
                if viewModel.isLoading {
                    ProgressView().padding()
                } else if let error = viewModel.errorMessage {
                    Text("오류: \(error)").foregroundColor(.errorRed)
                } else {
                    CarFilterSection(
                        title: "연식",
                        data: viewModel.carYears.map { (nil, $0, 0, false) },
                        onRowTap: { selectedCarYear in
                            filter.carYear = selectedCarYear
                            print("선택된 연식: \(selectedCarYear)")
                            
                            // 순차적으로 처리하여 부드럽게 만들기
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                onComplete?(filter)
                            }
                        }
                    )
                }
                
                Spacer(minLength: 40) // 하단 자리 확보
            }
//            .task {
//                if let category = filter.category ,
//                   let manufacturer = filter.manufacturer,
//                   let carName = filter.carName,
//                   let carModel = filter.modelName {
//                    await viewModel.fetchCarYears(category: category, manufacturer: manufacturer, carName: carName, modelName: carModel)
//                
//                    // 데이터 확인
//                            print("Fetched car years: \(viewModel.carYears)")
//                }
//            }
            .task {
                if let category = filter.category,
                   let manufacturer = filter.manufacturer,
                   let carName = filter.carName,
                   let carModel = filter.modelName {
                    await viewModel.fetchCarYears(category: category, manufacturer: manufacturer, carName: carName, modelName: carModel)
                }
            }
        }
    }
}
