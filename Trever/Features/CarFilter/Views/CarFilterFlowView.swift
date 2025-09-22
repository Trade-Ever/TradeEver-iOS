//
//  CarSelectionFlowView.swift
//  Trever
//
//  Created by OhChangEun on 9/22/25.
//

import SwiftUI

// 차량 필터 플로우를 담는 래퍼 뷰
struct CarFilterFlowView: View {
    @Binding var isPresented: Bool
    @ObservedObject var filter: CarFilterModel
    let includeYear: Bool
    let onComplete: (CarFilterModel) -> Void
    
    var body: some View {
        NavigationStack {
            CarManufacturerListView(
                filter: filter,
                includeYear: includeYear,
                onComplete: { completedFilter in
                    onComplete(completedFilter)
                    isPresented = false // 시트 닫기
                }
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        isPresented = false
                    }
                }
            }
        }
    }
}
