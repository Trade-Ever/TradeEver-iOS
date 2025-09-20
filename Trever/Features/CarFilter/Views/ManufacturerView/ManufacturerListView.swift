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

// 제조사 리스트 컴포넌트
struct ManufacturerListView: View {
    @ObservedObject var filter: CarFilterModel
    
    @State private var navigateToNext = false
    let onComplete: ((CarFilterModel) -> Void)? // 완료 콜백
    
    // 샘플 데이터
    let domesticCars: [(String, String, Int, Bool)] = [
        ("hyundai_logo", "현대", 44661, true),
        ("hyundai_logo", "제네시스", 11696, false),
        ("hyundai_logo", "기아", 11696, false),
        ("hyundai_logo", "쉐보레(GM 대우)", 11696, false),
        ("hyundai_logo", "르노코리아(삼성)", 11696, false)
    ]
    
    let importedCars: [(String, String, Int, Bool)] = [
        ("hyundai_logo", "BMW", 11696, false),
        ("hyundai_logo", "벤츠", 11696, false),
        ("hyundai_logo", "아우디", 11696, false),
        ("hyundai_logo", "포르쉐", 11696, false),
        ("hyundai_logo", "미니", 11696, false)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .center, spacing: 12) {
                    Text("제조사")
                        .font(.title3)
                        .bold()
                        .padding(.top, 32)
                        .padding(.bottom, 28)
                    
                    CarFilterSection(
                        title: "국산차",
                        data: domesticCars,
                        showDivider: true,
                        onRowTap: { selectedManufacturer in
                            filter.manufacturer = selectedManufacturer
                            print("선택된 제조사: \(selectedManufacturer)")
                            navigateToNext = true
                        }
                    )
                    
                    CarFilterSection(
                        title: "수입차",
                        data: importedCars,
                        onRowTap: { selectedManufacturer in
                            filter.manufacturer = selectedManufacturer
                            print("선택된 제조사: \(selectedManufacturer)")
                            navigateToNext = true
                        }
                    )
                    
                    Spacer(minLength: 40) // 하단 자리 확보
                }
            }
           .navigationDestination(isPresented: $navigateToNext) {
               CarModelListView(filter: filter, onComplete: onComplete) // 완료 콜백 전달
           }
        }
    }
}
