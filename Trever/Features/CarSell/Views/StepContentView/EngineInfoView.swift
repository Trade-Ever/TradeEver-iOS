//
//  EngineInfoPage.swift
//  Trever
//
//  Created by OhChangEun on 9/16/25.
//

import SwiftUI

struct EngineInfoView: View {
    @Binding var fuelType: String
    @Binding var transmission: String
    @Binding var displacement: String
    @Binding var horsepower: String
    
    @Binding var step: Int

    // FocusState
    enum Field: Hashable {
        case fuelType, transmission, displacement, horsepower
    }
    @FocusState private var focusedField: Field?
    
    let fuelOptions = ["경유", "휘발유", "전기", "LPG"] // 연료 버튼 배열
    let transmissionOptions = ["자동", "수동"] // 변속기 버튼 배열

    
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
                                    withAnimation(.easeInOut) { step = max(step, 1) }
                                    focusedField = .transmission
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 8)

                }
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
                                    withAnimation(.easeInOut) { step = max(step, 2) }
                                    focusedField = .displacement
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 8)
                }
            }

            
            // 3. 배기량(cc)
            if step >= 2 {
                InputSection(title: "배기량을 입력해주세요", subTitle: "(cc)") {
                    CustomInputBox(
                        inputType: .number,
                        placeholder: "1998",
                        text: $displacement
                    )
                    .focused($focusedField, equals: .displacement)
                    .onSubmit {
                        withAnimation(.easeInOut) { step = max(step, 3) }
                        focusedField = .horsepower
                    }
                }
            }
            
            // 4. 마력
            if step >= 3 {
                InputSection(title: "마력을 입력해주세요", subTitle: "(hp)") {
                    CustomInputBox(
                        inputType: .number,
                        placeholder: "150",
                        text: $horsepower
                    )
                    .focused($focusedField, equals: .horsepower)
                    .onSubmit {
                        focusedField = nil
                    }
                }
            }
        }
        .onAppear {
            focusedField = .fuelType
        }
    }
}

struct EngineInfoView_Previews: PreviewProvider {
    @State static var fuelType = ""
    @State static var transmission = ""
    @State static var displacement = ""
    @State static var horsepower = ""
    @State static var step = 0
    
    static var previews: some View {
        EngineInfoView(
            fuelType: $fuelType,
            transmission: $transmission,
            displacement: $displacement,
            horsepower: $horsepower,
            step: $step
        )
        .previewLayout(.sizeThatFits)
    }
}
