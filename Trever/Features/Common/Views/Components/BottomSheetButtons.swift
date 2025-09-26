//
//  BottomSheetButtons.swift
//  Trever
//
//  Created by OhChangEun on 9/16/25.
//

import SwiftUI

struct BottomSheetButtons: View {
    var title: String = "확인"
    var onConfirm: () -> Void
    var onReset: () -> Void
    
    var body: some View {
        HStack (spacing: 16) {
            // 초기화 버튼
            PrimaryButton(
                title: "초기화",
                fontSize: 18,
                cornerRadius: 50,
                height: 52,
                isOutline: true
            ) {
                onReset()
            }
            .frame(maxWidth: 120) // 고정 최대 너비
            
            // 확인 버튼
            PrimaryButton(
                title: title,
                fontSize: 18
                ,
                cornerRadius: 50,
                height: 52,
            ) {
                onConfirm()
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
}

// Preview
struct BottomSheetButtons_Previews: PreviewProvider {
    static var previews: some View {
        BottomSheetButtons(
            onConfirm: { print("확인 클릭") },
            onReset: { print("초기화 클릭") }
        )
    }
}
