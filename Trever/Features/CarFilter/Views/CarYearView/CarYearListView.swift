//
//  CarModelView.swift
//  Trever
//
//  Created by OhChangEun on 9/20/25.
//

import SwiftUI

// 차 모델
struct CarYearListView: View {
    @ObservedObject var filter: CarFilterModel
    @State private var navigateToNext = false
    let onComplete: ((CarFilterModel) -> Void)? // 콜백 받기

    // 샘플 데이터
    let carYears: [(String?, String, Int, Bool)] = [
        (nil, "2018년", 5, false),
        (nil, "2019년", 21, false),
        (nil, "2020년", 10, false),
        (nil, "2021년", 23, false),
        (nil, "2022년", 43, false),
        (nil, "2023년", 6, false),
        (nil, "2024년", 30, false),
        (nil, "2025년", 28, false),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 12) {
                Text(filter.carName ?? "연식 선택")
                    .font(.title3)
                    .bold()
                    .padding(.bottom, 36)
                
                CarFilterSection(
                    title: "연식",
                    data: carYears,
                    onRowTap: { selectedCarYear in
                        filter.carYear = selectedCarYear
                        print("선택된 연식: \(selectedCarYear)")
                        
                        // 순차적으로 처리하여 부드럽게 만들기
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            onComplete?(filter)
                        }
                        // onComplete?(filter) // 실제 콜백 호출
                    }
                )
                
                Spacer(minLength: 40) // 하단 자리 확보
            }
        }
    }
}
