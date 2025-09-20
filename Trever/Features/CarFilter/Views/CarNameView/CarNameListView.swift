//
//  CarModelView.swift
//  Trever
//
//  Created by OhChangEun on 9/20/25.
//

import SwiftUI

// 차 모델
struct CarNameListView: View {
    @ObservedObject var filter: CarFilterModel
    @State private var navigateToNext = false
    let onComplete: ((CarFilterModel) -> Void)? // 콜백 받기

    // 샘플 데이터
    let carNames: [(String?, String, Int, Bool)] = [
        // i30
        (nil, "i30", 100, false),
        (nil, "더 뉴 i30", 80, false),
        (nil, "i30 N", 60, false),
        
        // 쏘나타
        (nil, "쏘나타", 120, false),
        (nil, "더 뉴 쏘나타", 90, false),
        (nil, "쏘나타 DN8", 70, false),
        
        // 그랜저
        (nil, "그랜저", 80, false),
        (nil, "그랜저 하이브리드", 60, false),
        (nil, "더 뉴 그랜저", 50, false),
        
        // 아반떼
        (nil, "아반떼", 95, false),
        (nil, "더 뉴 아반떼", 75, false),
        (nil, "아반떼 N라인", 65, false),
        
        // 투싼
        (nil, "투싼", 85, false),
        (nil, "더 뉴 투싼", 70, false),
        (nil, "투싼 N라인", 55, false),
        
        // K5
        (nil, "K5", 70, false),
        (nil, "더 뉴 K5", 60, false),
        (nil, "K5 하이브리드", 50, false),
        
        // 스포티지
        (nil, "스포티지", 60, false),
        (nil, "더 뉴 스포티지", 50, false),
        
        // BMW 3시리즈
        (nil, "BMW 320", 50, false),
        (nil, "BMW 330", 40, false),
        (nil, "BMW 3시리즈 그란투리스모", 30, false),
        
        // 벤츠 C클래스
        (nil, "벤츠 C클래스", 45, false),
        (nil, "C클래스 AMG", 35, false),
        
        // 아우디 A4
        (nil, "아우디 A4", 40, false),
        (nil, "A4 콰트로", 30, false)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 12) {
                Text(filter.modelName ?? "모델 선택")
                    .font(.title3)
                    .bold()
                    .padding(.bottom, 36)
                
                CarFilterSection(
                    title: "세부 모델",
                    data: carNames,
                    onRowTap: { selectedCarName in
                        filter.carName = selectedCarName
                        print("선택된 차명: \(selectedCarName)")
                        navigateToNext = true
                    }
                )
                
                Spacer(minLength: 40) // 하단 자리 확보
            }
        }
        .navigationDestination(isPresented: $navigateToNext) {
            CarYearListView(filter: filter, onComplete: onComplete)
        }
    }
}
