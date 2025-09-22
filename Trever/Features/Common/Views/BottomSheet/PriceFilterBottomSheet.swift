//
//  YearFilterBottomSheet.swift
//  Trever
//
//  Created by OhChangEun on 9/22/25.
//

import SwiftUI

struct PriceFilterBottomSheet: View {
    @Binding var isPresented: Bool
    @Binding var selectedPriceRange: ClosedRange<Double>

    private let minPrice: Double = 0     // 천만원 단위(0원)
    private let maxPrice: Double = 30    // 천만원 단위(30억)
    private let step: Double = 1         // 천만원 단위

    var body: some View {
        VStack(spacing: 0) {
            // 핸들
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.grey200)
                .frame(width: 36, height: 5)
                .padding(.vertical, 18)
            
            // 제목
            Text("가격을 선택해주세요")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(Color.grey400)
                .padding(.top, 4)
                .padding(.bottom, 32)
            
            // 선택된 값 표시
            HStack {
                Text(Formatters.priceToEokFormat(selectedPriceRange.lowerBound))
                    .font(.system(size: 32))
                    .foregroundColor(.purple300)
                    .fontWeight(.heavy)
                
                Text("~")
                    .font(.headline)
                    .font(.system(size: 40))
                    .foregroundColor(.purple200)
                    .bold()
                
                Text(Formatters.priceToEokFormat(selectedPriceRange.upperBound))
                    .font(.system(size: 32))
                    .foregroundColor(.purple300)
                    .fontWeight(.heavy)
            }
            .padding(.horizontal, 20)
            
            VStack(spacing: 2) {
                RangeSlider(
                    range: $selectedPriceRange,
                    minValue: minPrice,
                    maxValue: maxPrice,
                    step: step
                )
                .padding(.horizontal, 24)
                
                // 최소/최대 표시
                HStack {
                    Text(Formatters.priceToEokFormat(minPrice))
                        .font(.caption)
                        .foregroundColor(Color.grey400)
                    Spacer()
                    Text(Formatters.priceToEokFormat(maxPrice))
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
                    selectedPriceRange = minPrice...maxPrice
                }
            )
        }
    }
}
