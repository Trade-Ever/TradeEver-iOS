//
//  SwiftUIView.swift
//  Trever
//
//  Created by OhChangEun on 9/16/25.
//

import SwiftUI

struct AccidentInfoView: View {
    @Binding var accidentHistory: String
    @Binding var accidentDescription: String

    @Binding var step: Int

    // FocusState
    enum Field: Hashable {
        case detailedDescription
    }
    @FocusState private var focusedField: Field?
    
    let accidentOptions = ["있음", "없음"]
    
    var body: some View {
        VStack(spacing: 12) {
            
            // 0. 사고 이력 선택
            if step >= 0 {
                InputSection(title: "사고 이력을 선택해주세요") {
                    HStack(spacing: 16) {
                        ForEach(accidentOptions, id: \.self) { option in
                            SelectableButton(
                                title: option,
                                isSelected: accidentHistory == option,
                                action: {
                                    accidentHistory = option
                                    // 선택하면 다음 step으로
                                    withAnimation(.easeInOut) { step = max(step, 1) }
                                    focusedField = .detailedDescription
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 8)
                }
                .stepTransition(step: step, target: 0)
            }
            
            // 1. 상세 설명 입력
            if step >= 1 {
                InputSection(title: "사고 정보에 대해 입력해주세요") {
                    CustomMultilineInputBox(
                        placeholder: "차량 상태, 사고 여부, 관리 이력 등",
                        text: $accidentDescription
                    )
                    .focused($focusedField, equals: .detailedDescription)
                    .onSubmit {
                        focusedField = nil
                    }
                }
                .frame(height: 240)
                .padding(.bottom, 100)
                .stepTransition(step: step, target: 1)
            }
        }
    }
}

struct AccidentInfoView_Previews: PreviewProvider {
    @State static var accidentHistory = ""
    @State static var accidentDescription = ""
    @State static var step = 0

    static var previews: some View {
        AccidentInfoView(
            accidentHistory: $accidentHistory,
            accidentDescription: $accidentDescription,
            step: $step
        )
        .previewLayout(.sizeThatFits)
    }
}
