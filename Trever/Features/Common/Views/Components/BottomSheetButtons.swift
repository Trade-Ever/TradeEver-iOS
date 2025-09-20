//
//  BottomSheetButtons.swift
//  Trever
//
//  Created by OhChangEun on 9/16/25.
//

import SwiftUI

struct BottomSheetButtons: View {
    var onConfirm: () -> Void
    var onReset: () -> Void
    
    var body: some View {
        HStack (spacing: 16) {
            // 초기화 버튼
            PrimaryButton(
                title: "초기화",
                fontSize: 20,
                cornerRadius: 50,
                height: 52,
                isOutline: true
            ) {
                onReset()
            }
            
            // 확인 버튼
            PrimaryButton(
                title: "확인",
                fontSize: 20,
                cornerRadius: 50,
                height: 52,
            ) {
                onConfirm()
            }
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
