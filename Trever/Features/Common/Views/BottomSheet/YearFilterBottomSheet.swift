//
//  YearFilterBottomSheet.swift
//  Trever
//
//  Created by OhChangEun on 9/22/25.
//

import SwiftUI

struct YearFilterBottomSheet: View {
    @Binding var isPresented: Bool
    @Binding var selectedYearRange: ClosedRange<Double>
    
    private let minYear: Double = 1998
    private let maxYear: Double = 2025
    
    var body: some View {
        VStack(spacing: 0) {
            // 핸들
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.grey200)
                .frame(width: 36, height: 5)
                .padding(.vertical, 18)
            
            // 제목
            Text("연식 범위를 선택해주세요")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(Color.grey400)
                .padding(.top, 4)
                .padding(.bottom, 32)
            
            // 선택된 값 표시
            HStack {
                Text("\(Int(selectedYearRange.lowerBound))년")
                    .font(.system(size: 32))
                    .foregroundColor(.purple300)
                    .fontWeight(.heavy)

                Text("~")
                    .font(.headline)
                    .font(.system(size: 40))
                    .foregroundColor(.purple200)
                    .bold()
                
                Text("\(Int(selectedYearRange.upperBound))년")
                    .font(.system(size: 32))
                    .foregroundColor(.purple300)
                    .fontWeight(.heavy)
                }
                .padding(.horizontal, 20)
            
            VStack(spacing: 2) {
                RangeSlider(
                    range: $selectedYearRange,
                    minValue: minYear,
                    maxValue: maxYear,
                    step: 1
                )
                .padding(.horizontal, 24)
                
                // 최소/최대 표시
                HStack {
                    Text("\(Int(minYear))년")
                        .font(.caption)
                        .foregroundColor(Color.grey400)
                    Spacer()
                    Text("\(Int(maxYear))년")
                        .font(.caption)
                        .foregroundColor(Color.grey400)
                }
                .padding(.horizontal, 10)
            }
            .padding(20)
            
            Spacer()

            // 버튼
            BottomSheetButtons(
                title: "적용",
                onConfirm: {
                    isPresented = false
                },
                onReset: {
                    selectedYearRange = minYear...maxYear
                }
            )
        }
    }
}
