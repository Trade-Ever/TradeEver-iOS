//
//  CarModelView.swift
//  Trever
//
//  Created by OhChangEun on 9/20/25.
//

import SwiftUI

// 차명 목록
struct CarNameListView: View {
    @ObservedObject var filter: CarFilterModel
    @StateObject private var viewModel = CarNameViewModel()

    @State private var navigateToNext = false
    let onComplete: ((CarFilterModel) -> Void)? // 콜백 받기

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 12) {

                if viewModel.isLoading {
                    ProgressView().padding()
                } else if let error = viewModel.errorMessage {
                    Text("오류: \(error)").foregroundColor(.errorRed)
                } else {
                    Text(filter.manufacturer ?? "모델 선택")
                        .font(.title3)
                        .bold()
                        .padding(.bottom, 36)
                    
                    CarFilterSection(
                        title: "모델 목록",
                        data: viewModel.carNames.map{ (nil, $0, 0, false) },
                        onRowTap: { selectedCarName in
                            filter.carName = selectedCarName
                            print("선택된 차량 이름: \(selectedCarName)")
                            navigateToNext = true
                        }
                    )
                }
    
                Spacer(minLength: 40) // 하단 자리 확보
            }
            .task {
                if let category = filter.category,
                   let manufacturer = filter.manufacturer {
                    await viewModel.fetchCarNames(category: category, manufacturer: manufacturer)
                }
            }
        }
        .navigationDestination(isPresented: $navigateToNext) {
            CarModelListView(filter: filter, onComplete: onComplete)
        }
    }
}
