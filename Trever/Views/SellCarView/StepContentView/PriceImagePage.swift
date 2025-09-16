//
//  VehicleNamePage.swift
//  Trever
//
//  Created by OhChangEun on 9/16/25.
//

import SwiftUI

struct PriceImagePage: View {
    @State private var selectedYear = 2025
    
    // 연도 배열 생성
    let years = Array(2000...2025)
    
    var body: some View {
        VStack {
            Text("선택된 연도: \(selectedYear)")
                .font(.title)
                .padding()
            
            Picker("연도 선택", selection: $selectedYear) {
                ForEach(years, id: \.self) { year in
                    Text("\(year)년").tag(year)
                        .font(.system(size: 32, weight: .bold)) // 글자 크기와 굵기
                        .foregroundColor(.grey400) // 글자 색상
                    
                }
            }
            .pickerStyle(WheelPickerStyle()) // 스크롤 휠 스타일
            .frame(height: 250)
        }
    }
}

#Preview {
    PriceImagePage()
}
