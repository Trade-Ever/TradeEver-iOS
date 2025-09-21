//
//  CarModelView.swift
//  Trever
//
//  Created by OhChangEun on 9/20/25.
//

import SwiftUI

// 차 모델 목록
struct CarModelListView: View {
    @ObservedObject var filter: CarFilterModel
    @StateObject private var viewModel = CarModelsViewModel()
    
    @State private var navigateToNext = false
    let onComplete: ((CarFilterModel) -> Void)? // 콜백 받기

//    // 아우디 A4
//    (nil, "아우디 A4", 40, false),
//    (nil, "A4 콰트로", 30, false)

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 12) {

                if viewModel.isLoading {
                    ProgressView().padding()
                } else if let error = viewModel.errorMessage {
                    Text("오류: \(error)").foregroundColor(.errorRed)
                } else {
                    Text(filter.carName ?? "모델 선택")
                        .font(.title3)
                        .bold()
                        .padding(.bottom, 36)
                    
                    CarFilterSection(
                        title: "세부 모델",
                        data: viewModel.carModels.map { (nil, $0, 0, false) },
                        onRowTap: { selectedCarModel in
                            filter.modelName = selectedCarModel
                            print("선택된 차량 모델: \(selectedCarModel)")
                            navigateToNext = true
                        }
                    )
                }
                
                Spacer(minLength: 40) // 하단 자리 확보
            }
            .task {
                if let category = filter.category ,
                   let manufacturer = filter.manufacturer,
                   let carName = filter.carName {
                    await viewModel.fetchCarModels(category: category, manufacturer: manufacturer, carName : carName)
                }
            }
        }
        .navigationDestination(isPresented: $navigateToNext) {
            CarYearListView(filter: filter, onComplete: onComplete)
        }
    }
}
