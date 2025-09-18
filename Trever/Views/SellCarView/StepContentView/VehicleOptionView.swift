//
//  VehicleNamePage.swift
//  Trever
//
//  Created by OhChangEun on 9/16/25.
//

import SwiftUI

struct VehicleOptionView: View {
    @Binding var vehicleOptions: String
    @Binding var detailedDescription: String
    
    @Binding var step: Int
    
    enum Field: Hashable {
        case vehicleOptions, detailedDescription
    }
    @FocusState private var focusedField: Field?
    
    @State private var showCarOptionSheet = false
    @State private var selectedCarOptions: [String] = []
    
    var body: some View {
        //        ScrollView {
        //
        //        }
        //        .ignoresSafeArea(.keyboard) // 키보드가 safe area를 침범할 수 있게
        VStack(spacing: 6) {
            
            // 1. 차량 옵션
            if step >= 0 {
                InputSection(title: "차량 옵션을 입력해주세요") {
                    CustomInputBox(
                        placeholder: "썬루프, 네비게이션, 하이패스 등",
                        showSheet: true,
                        text: $vehicleOptions
                    )
                    .onTapGesture {
                        showCarOptionSheet = true
                    }
                    .focused($focusedField, equals: .vehicleOptions)
                }
                .stepTransition(step: step, target: 0)
            }
            
            // 2. 상세 설명
            if step >= 1 {
                InputSection(title: "상세 설명을 입력해주세요") {
                    CustomMultilineInputBox(
                        placeholder: "차량 상태, 사고 여부, 관리 이력 등",
                        text: $detailedDescription,
                    )
                    .focused($focusedField, equals: .detailedDescription)
                    .onSubmit {
                        focusedField = nil
                    }
                }
                .frame(height: 240)
                .stepTransition(step: step, target: 1)
            }
        }
        .onAppear {
            focusedField = .vehicleOptions
        }
        .sheet(isPresented: $showCarOptionSheet) {
            CarOptionBottomSheet(
                isPresented: $showCarOptionSheet,
                selectedCarOptions: $selectedCarOptions
            )
            .onDisappear {
                // 시트 닫힐 때 InputBox 업데이트
                vehicleOptions = selectedCarOptions.joined(separator: ", ")
                
                // 차 옵션 선택 후 다음 단계로 이동
                if !selectedCarOptions.isEmpty {
                    withAnimation(.easeInOut) {
                        step = max(step, 1)
                        focusedField = .detailedDescription
                    }
                }
            }
            .presentationDetents([.fraction(0.4)]) // 화면의 40% 차지
        }
    }
}

struct VehicleOptionView_Previews: PreviewProvider {
    @State static var vehicleOptions = ""
    @State static var detailedDescription = ""
    @State static var step = 0
    
    static var previews: some View {
        VehicleOptionView(
            vehicleOptions: $vehicleOptions,
            detailedDescription: $detailedDescription,
            step: $step
        )
        .previewLayout(.sizeThatFits)
    }
}
