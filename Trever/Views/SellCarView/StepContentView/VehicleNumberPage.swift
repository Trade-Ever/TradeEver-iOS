//
//  VehicleNamePage.swift
//  Trever
//
//  Created by OhChangEun on 9/16/25.
//

import SwiftUI

struct VehicleNumberPage: View {
    @State private var number: String = "" // 차량 번호 상태 저장
    
    var body: some View {
        InputSection(title: "등록할 차량 번호를 입력해주세요") {
            VehicleNumberInput(text: $number)
                .padding(.horizontal, 8)
        }
    }
}

struct VehicleNumberInput: View {
    @Binding var text: String

    var body: some View {
        // 번호판 스타일 InputBox
        HStack {
            // 왼쪽 동그라미
            Circle()
                .stroke(Color.grey300, lineWidth: 1)
                .frame(width: 12, height: 12)
                .padding(.leading, 4)
            
            // 입력창
            TextField("23가 4821", text: $text)
                .multilineTextAlignment(.center) // 가운데 정렬
                .font(.largeTitle)
                .bold()
                .foregroundColor(.black)
                .padding(.horizontal, 12)
            
            // 오른쪽 동그라미
            Circle()
                .stroke(Color.grey300, lineWidth: 1)
                .frame(width: 12, height: 12)
                .padding(.trailing, 4)

        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .overlay(
            // 바깥 테두리
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.grey400, lineWidth: 3)
        )
    }
    
}

#Preview {
    VehicleNumberPage()
}
