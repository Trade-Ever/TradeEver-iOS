//
//  PressableButtonStyle.swift
//  Trever
//
//  Created by OhChangEun on 9/20/25.
//

import SwiftUI

// 재사용 가능한 PressableRow 컴포넌트
struct PressableRow<Content: View>: View {
    let onTap: () -> Void
    let content: Content
    
    @State private var isPressed = false
    @State private var isTapped = false
    
    init(onTap: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.onTap = onTap
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(.horizontal)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(isPressed || isTapped ? Color.grey100 : Color.white)
            .cornerRadius(8)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        // 손가락이 거의 움직이지 않았다면 눌림 상태
                        if abs(value.translation.width) < 5 && abs(value.translation.height) < 5 {
                            isPressed = true
                        } else {
                            isPressed = false
                        }
                    }
                    .onEnded { value in
                        if abs(value.translation.width) < 5 && abs(value.translation.height) < 5 {
                            // 클릭 처리 + 잠시 색상 유지
                            isTapped = true
                            onTap()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                isTapped = false
                            }
                        }
                        isPressed = false
                    }
            )
    }
}
