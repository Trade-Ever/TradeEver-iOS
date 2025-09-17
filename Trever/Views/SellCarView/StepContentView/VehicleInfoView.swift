//
//  VehicleNamePage.swift
//  Trever
//
//  Created by OhChangEun on 9/16/25.
//

import SwiftUI

struct VehicleOptionView: View {
    @State private var vehicleModel: String = ""
    @State private var year: String = ""
    @State private var carType: String = ""
    @State private var mileage: String = ""
    
    @State private var step: Int = 0
    
    // FocusState
    enum Field: Hashable {
        case vehicleModel, year, carType, mileage
    }
    @FocusState private var focusedField: Field?
    
    // 바텀 시트 상태
    @State private var showCarTypeSheet = false
    @State private var selectedCarTypes: [String] = []
    
    
    var body: some View {
        VStack(spacing: 12) {
            
            // 1. 차량 모델
            if step >= 0 {
                InputSection(title: "차량 모델을 선택해주세요") {
                    CustomInputBox(placeholder: "현대 아반떼 SN7", text: $vehicleModel)
                        .focused($focusedField, equals: .vehicleModel)
                        .onSubmit {
                            withAnimation(.easeInOut) { step = 1 }
                            focusedField = .year
                        }
                }
                .stepTransition(step: step, target: 0)
            }
            
            // 2. 연식
            if step >= 1 {
                InputSection(title: "연식을 입력해주세요") {
                    CustomInputBox(placeholder: "2023년", text: $year)
                        .focused($focusedField, equals: .year)
                        .onSubmit {
                            withAnimation(.easeInOut) { step = 2 }
                            focusedField = .carType
                        }
                }
                .stepTransition(step: step, target: 1)
            }
            
            // 3. 차종
            if step >= 2 {
                InputSection(title: "차종을 선택해주세요") {
                    CustomInputBox(
                        placeholder: "대형, 준중형 등",
                        isEditable: false,
                        text: $carType,
                    )
                    .onTapGesture {
                        showCarTypeSheet = true
                    }
                }
                .stepTransition(step: step, target: 2)
            }
            
            // 4. 주행거리
            if step >= 3 {
                InputSection(title: "주행거리를 입력해주세요") {
                    CustomInputBox(placeholder: "11,234km", text: $mileage)
                        .focused($focusedField, equals: .mileage)
                        .onSubmit {
                            // 마지막 단계
                            focusedField = nil
                        }
                }
                .stepTransition(step: step, target: 3)
            }
        }
        .onAppear {
            focusedField = .vehicleModel // 처음 박스 포커스
        }
        .sheet(isPresented: $showCarTypeSheet) {
            CarTypeBottomSheet(
                isPresented: $showCarTypeSheet,
                selectedCarTypes: $selectedCarTypes
            )
            .onDisappear {
                // 시트 닫힐 때 InputBox 업데이트
                carType = selectedCarTypes.joined(separator: ", ")
                
                // 차종 선택 후 다음 단계로 이동
                if !selectedCarTypes.isEmpty {
                    withAnimation(.easeInOut) {
                        step = 3
                        focusedField = .mileage
                    }
                }
            }
            .presentationDetents([.fraction(0.45)]) // 화면의 50% 차지
        }
    }
}

#Preview {
    VehicleOptionView()
}
