//
//  YearFilterBottomSheet.swift
//  Trever
//
//  Created by OhChangEun on 9/22/25.
//

import SwiftUI

struct MileageFilterBottomSheet: View {
    @Binding var isPresented: Bool
    @Binding var selectedMileageRange: ClosedRange<Double>
    let action: () -> Void

    private let minMileage: Double = 0
    private let maxMileage: Double = 30 // km 단위
    private let step: Double = 1        // km 단위

    var body: some View {
        VStack(spacing: 0) {
            // 핸들
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.grey200)
                .frame(width: 36, height: 5)
                .padding(.vertical, 18)
            
            // 제목
            Text("주행 거리를 선택해주세요")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(Color.grey400)
                .padding(.top, 4)
                .padding(.bottom, 32)
            
            // 선택된 값 표시
            HStack {
                Text("\(Int(selectedMileageRange.lowerBound))만 km")
                    .font(.system(size: 32))
                    .foregroundColor(.purple300)
                    .fontWeight(.heavy)

                Text("~")
                    .font(.headline)
                    .font(.system(size: 40))
                    .foregroundColor(.purple200)
                    .bold()
                
                Text("\(Int(selectedMileageRange.upperBound))만 km")
                    .font(.system(size: 32))
                    .foregroundColor(.purple300)
                    .fontWeight(.heavy)
                }
                .padding(.horizontal, 20)
            
            VStack(spacing: 2) {
                RangeSlider(
                    range: $selectedMileageRange,
                    minValue: minMileage,
                    maxValue: maxMileage,
                    step: step
                )
                .padding(.horizontal, 24)
                
                // 최소/최대 표시
                HStack {
                    Text("\(Int(minMileage))년")
                        .font(.caption)
                        .foregroundColor(Color.grey400)
                    Spacer()
                    Text("\(Int(maxMileage))년")
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
                    action()
                    isPresented = false
                },
                onReset: {
                    selectedMileageRange = minMileage...maxMileage
                }
            )
        }
    }
}
