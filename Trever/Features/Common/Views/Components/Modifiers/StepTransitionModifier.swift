//
//  StepTransitionModifier.swift
//  Trever
//
//  Created by OhChangEun on 9/17/25.
//

import SwiftUI

/// 공통 애니메이션 모디파이어
struct StepTransitionModifier: ViewModifier {
    let step: Int      // 현재 단계
    let target: Int    // 이 뷰가 표시되는 단계
    
    func body(content: Content) -> some View {
        content
            .opacity(step >= target ? 1 : 0)
            .offset(y: step >= target ? 0: 100)
            .animation(.easeInOut(duration: 1), value: step)
    }
}

extension View {
    func stepTransition(step: Int, target: Int) -> some View {
        self.modifier(StepTransitionModifier(step: step, target: target))
    }
}
