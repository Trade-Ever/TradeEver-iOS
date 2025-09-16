//
//  StepButtonView.swift
//  Trever
//
//  Created by OhChangEun on 9/16/25.
//

import SwiftUI

struct StepButton: View {
    @Binding var currentStep: Int
    let totalSteps: Int
    @Binding var userInput: String
    
    var body: some View {
        CustomButton(
            title: currentStep == totalSteps - 1 ? "완료" : "다음",
            action: {
                if currentStep < totalSteps - 1 {
                    currentStep += 1
                    userInput = "" // 다음 단계 입력 초기화
                } else {
                    print("모든 단계 완료")
                }
            },
        )
        .padding(.bottom, 20)
    }
}

