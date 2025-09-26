//
//  StepActionButton.swift
//  Trever
//
//  Created by OhChangEun on 9/18/25.
//

import SwiftUI

public struct StepActionBar: View {
    let currentStep: Int
    let totalSteps: Int
    let onNext: () -> Void
    let onPrevious: () -> Void
    let isStepCompleted: (Int) -> Bool

    public init(
        currentStep: Int,
        totalSteps: Int,
        onNext: @escaping () -> Void,
        onPrevious: @escaping () -> Void,
        isStepCompleted: @escaping (Int) -> Bool
    ) {
        self.currentStep = currentStep
        self.totalSteps = totalSteps
        self.onNext = onNext
        self.onPrevious = onPrevious
        self.isStepCompleted = isStepCompleted
    }

    public var body: some View {
        HStack(spacing: 16) {
            if currentStep > 0 {
                PrimaryButton(
                    title: "이전",
                    isOutline: true
                ) {
                    onPrevious()
                }
                .frame(width: 120)
            }
            
            PrimaryButton(
                title: currentStep == totalSteps - 1 ? "등록하기" : "다음",
                action: onNext
            )
            .frame(maxWidth: .infinity)
            .opacity(isStepCompleted(currentStep) ? 1.0 : 0.5)
            .disabled(!isStepCompleted(currentStep))
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color(UIColor.systemBackground))
    }
}

struct StepActionBar_Previews: PreviewProvider {
    @State static var currentStep = 1
    static let totalSteps = 3

    static var previews: some View {
        VStack {
            StepActionBar(
                currentStep: currentStep,
                totalSteps: totalSteps,
                onNext: {
                    print("다음 버튼 클릭")
                    if currentStep < totalSteps - 1 {
                        currentStep += 1
                    }
                },
                onPrevious: {
                    print("이전 버튼 클릭")
                    if currentStep > 0 {
                        currentStep -= 1
                    }
                },
                isStepCompleted: { step in
                    // 예시: 모든 단계 완료로 처리
                    return true
                }
            )
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
