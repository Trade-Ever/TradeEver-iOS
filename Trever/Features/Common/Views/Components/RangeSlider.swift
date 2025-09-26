//  RangeSlider.swift
//  Trever
//
//  Created by ChatGPT on 2025/09/22.
//

import SwiftUI

struct RangeSlider: View {
    @Binding var range: ClosedRange<Double>  // 현재 값 (ex: 10...50)
    
    let minValue: Double                     // 최소값
    let maxValue: Double                     // 최대값
    let step: Double                         // 단위 간격
    
    private var totalSteps: Int {
        Int((maxValue - minValue) / step)
    }
    
    private func stepValue(_ value: Double) -> Double {
        let steppedValue = (round((value - minValue) / step) * step) + minValue
        return max(minValue, min(maxValue, steppedValue)) // 범위 제한
    }
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let startX = CGFloat((range.lowerBound - minValue) / (maxValue - minValue)) * width
            let endX   = CGFloat((range.upperBound - minValue) / (maxValue - minValue)) * width
            
            ZStack(alignment: .leading) {
                // 전체 바
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.grey200)
                    .frame(height: 8)
                
                // 선택된 구간
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.purple300)
                    .frame(width: endX - startX, height: 8)
                    .offset(x: startX)
                
                // 시작 핸들
                Circle()
                    .fill(Color.white)
                    .overlay(Circle().stroke(Color.grey300, lineWidth: 1))
                    .frame(width: 28, height: 28)
                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 1)
                    .position(x: startX, y: 14)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let dragX = max(0, min(width, value.location.x)) // 드래그 범위 제한
                                let newValue = stepValue(Double(dragX / width) * (maxValue - minValue) + minValue)
                                let constrainedValue = min(newValue, range.upperBound) // 상한선 제한
                                range = constrainedValue...range.upperBound
                            }
                    )
                
                // 끝 핸들
                Circle()
                    .fill(Color.white)
                    .overlay(Circle().stroke(Color.grey300, lineWidth: 1))
                    .frame(width: 28, height: 28)
                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 1)
                    .position(x: endX, y: 14)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let dragX = max(0, min(width, value.location.x)) // 드래그 범위 제한
                                let newValue = stepValue(Double(dragX / width) * (maxValue - minValue) + minValue)
                                let constrainedValue = max(newValue, range.lowerBound) // 하한선 제한
                                range = range.lowerBound...constrainedValue
                            }
                    )
            }
            .frame(height: 30)
            
        }
        .frame(height: 40)
    }
}
