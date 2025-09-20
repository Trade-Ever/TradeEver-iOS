//
//  ManufacturerListView.swift
//  Trever
//
//  Created by OhChangEun on 9/19/25.
//

import SwiftUI

// 제조사 아이템 컴포넌트
struct CarFilterRow: View {
    let image: String?       // 이미지 이름 (Asset)
    let name: String         // 이름
    let count: Int           // 필터링된 수
    let isSelected: Bool     // 선택 여부
    let onTap: () -> Void    // 클릭 액션 전달
    
    @State private var isPressed = false
    
    var body: some View {
        HStack (spacing: 0) {
            if let image = image, !image.isEmpty {
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 34, height: 34)
            }
            Spacer().frame(width: 12)
            
            Text(name)
                .foregroundColor(isSelected ? Color.purple400 : .grey400)
                .font(.system(size: 15))
            
            Spacer()
            
            if count >= 0 {
                Text("\(count)")
                    .foregroundColor(Color.grey300.opacity(0.7))
                    .font(.system(size: 14))
                    .padding(.trailing, 5)
            }
            
            Image(systemName: "chevron.right")
                .resizable()
                .scaledToFit()
                .frame(width: 10, height: 10)
                .foregroundStyle(Color.grey200.opacity(0.8))
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, minHeight: 48)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isPressed ? Color.grey200.opacity(0.3) : Color.white) // 버튼 눌릴 때 색상 변경
        )
        .cornerRadius(8)
        .onTapGesture {
            // 눌린 상태로 변경
            withAnimation(.easeIn(duration: 0.05)) {
                isPressed = true
            }

            // 잠시 후 원래 상태로 복귀
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeOut(duration: 0.2)) {
                    isPressed = false
                    onTap()
                }
            }
        }
        /*
         // 스크롤과 겹치는 문제가 있음
         .gesture(
             DragGesture(minimumDistance: 0)
                 .onChanged { _ in
                     withAnimation(.easeIn(duration: 0.05)) { isPressed = true }
                 }
                 .onEnded { _ in
                     withAnimation(.easeOut(duration: 0.2)) { isPressed = false }
                     onTap() // onTap 클로저 호출 추가
                 }
             
         )
         */
    }
}

#Preview {
    VStack(spacing: 12) {
        CarFilterRow(
            image: "hyundai_logo",
            name: "현대",
            count: 123,
            isSelected: true,
            onTap: { print("현대 클릭됨") }
        )
        
        CarFilterRow(
            image: nil, // 이미지 없음
            name: "기아",
            count: 56,
            isSelected: false,
            onTap: { print("기아 클릭됨") }
        )
    }
}
