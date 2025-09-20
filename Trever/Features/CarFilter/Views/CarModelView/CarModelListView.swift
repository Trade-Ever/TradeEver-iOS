//
//  CarModelView.swift
//  Trever
//
//  Created by OhChangEun on 9/20/25.
//

import SwiftUI

// 차 모델
struct CarModelListView: View {
    @ObservedObject var filter: CarFilterModel
    @State private var navigateToNext = false
    let onComplete: ((CarFilterModel) -> Void)? // 콜백 받기

    // 샘플 데이터
    let models: [(String?, String, Int, Bool)] = [
        (nil, "i30", 100, false),
        (nil, "쏘나타", 120, false),
        (nil, "그랜저", 80, false),
        (nil, "아반떼", 95, false),
        (nil, "투싼", 85, false),
        (nil, "K5", 70, false),
        (nil, "스포티지", 60, false),
        (nil, "BMW 3시리즈", 50, false),
        (nil, "벤츠 C클래스", 45, false),
        (nil, "아우디 A4", 40, false)
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 12) {
                Text(filter.manufacturer ?? "모델 선택")
                    .font(.title3)
                    .bold()
                    .padding(.bottom, 36)
                
                CarFilterSection(
                    title: "모델 목록",
                    data: models,
                    onRowTap: { selectedModel in
                        filter.modelName = selectedModel
                        print("선택된 차량 모델: \(selectedModel)")
                        navigateToNext = true
                    }
                )
                
                Spacer(minLength: 40) // 하단 자리 확보
            }
        }
        .navigationDestination(isPresented: $navigateToNext) {
            CarNameListView(filter: filter, onComplete: onComplete)
        }
    }
}
