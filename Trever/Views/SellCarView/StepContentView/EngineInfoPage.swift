//
//  EngineInfoPage.swift
//  Trever
//
//  Created by OhChangEun on 9/16/25.
//

import SwiftUI

struct EngineInfoPage: View {
    @State private var fuelType: String = ""
    @State private var transmission: String = ""
    @State private var displacement: String = ""
    @State private var horsepower: String = ""
    
    @State private var step: Int = 0
    
    // FocusState
    enum Field: Hashable {
        case fuelType, transmission, displacement, horsepower
    }
    @FocusState private var focusedField: Field?
    
    // 연료 버튼 배열
    let fuelOptions = ["경유", "휘발유", "전기", "LPG"]
    
    // 변속기 버튼 배열
    let transmissionOptions = ["자동", "수동"]
    
    var body: some View {
        VStack(spacing: 12) {
            
            // 1. 연료
            if step >= 0 {
                InputSection(title: "연료를 선택해주세요") {
                    HStack(spacing: 8) {
                        ForEach(fuelOptions, id: \.self) { type in
                            SelectableButton(
                                title: type,
                                isSelected: fuelType == type,
                                action: {
                                    fuelType = type
                                    // 선택하면 다음 step으로
                                    withAnimation(.easeInOut) { step = 1 }
                                    focusedField = .transmission
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 8)

                }
                .transition(.opacity)
                .offset(y: step >= 0 ? 0 : 30)
                .animation(.easeInOut, value: step)
            }

            // 2. 변속기
            if step >= 1 {
                InputSection(title: "변속기를 선택해주세요") {
                    HStack(spacing: 16) {
                        ForEach(transmissionOptions, id: \.self) { type in
                            SelectableButton(
                                title: type,
                                isSelected: transmission == type,
                                action: {
                                    transmission = type
                                    // 선택하면 다음 step으로
                                    withAnimation(.easeInOut) { step = 2 }
                                    focusedField = .displacement
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 8)
                }
                .transition(.opacity)
                .offset(y: step >= 0 ? 0 : 30)
                .animation(.easeInOut, value: step)
            }

            
            // 3. 배기량(cc)
            if step >= 2 {
                InputSection(title: "배기량(CC)을 입력해주세요") {
                    CustomInputBox(
                        placeholder: "1998",
                        text: $displacement
                    )
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .displacement)
                    .onSubmit {
                        withAnimation(.easeInOut) { step = 3 }
                        focusedField = .horsepower
                    }
                }
                .transition(.opacity)
                .offset(y: step >= 0 ? 0 : 30)
                .animation(.easeInOut, value: step)
            }
            
            // 4. 마력
            if step >= 3 {
                InputSection(title: "마력을 입력해주세요") {
                    CustomInputBox(
                        placeholder: "150",
                        text: $horsepower
                    )
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .horsepower)
                    .onSubmit {
                        focusedField = nil
                    }
                }
                .transition(.opacity)
                .offset(y: step >= 0 ? 0 : 30)
                .animation(.easeInOut, value: step)
            }
        }
        .onAppear {
            focusedField = .fuelType
        }
    }
}

#Preview {
    EngineInfoPage()
}
