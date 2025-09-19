import SwiftUI

struct VehicleInfoView: View {
    @Binding var vehicleModel: String
    @Binding var vehicleYear: String
    @Binding var vehicleType: String
    @Binding var vehicleMileage: String
    
    @Binding var step: Int
    
    // FocusState
    enum Field: Hashable {
        case vehicleModel, year, carType, mileage
    }
    @FocusState private var focusedField: Field?
    
    // 바텀 시트 상태
    @State private var showCarTypeSheet = false
    @State private var selectedCarType: String? = nil // 단일 선택

    var body: some View {
        VStack(spacing: 7) {
            // 1. 차량 모델
            if step >= 0 {
                InputSection(title: "차량 모델을 선택해주세요") {
                    CustomInputBox(placeholder: "현대 아반떼 SN7", text: $vehicleModel)
                        .focused($focusedField, equals: .vehicleModel)
                        .id(Field.vehicleModel)
                        .onSubmit {
                            withAnimation(.easeInOut) { step = max(step, 1) }
                            focusedField = .year
                        }
                }
            }
            
            // 2. 연식
            if step >= 1 {
                InputSection(title: "연식을 입력해주세요") {
                    CustomInputBox(placeholder: "2023년", text: $vehicleYear)
                        .focused($focusedField, equals: .year)
                        .id(Field.year)
                        .onSubmit {
                            withAnimation(.easeInOut) { step = max(step, 2) }
                            focusedField = .carType
                        }
                }
            }
            
            // 3. 차종
            if step >= 2 {
                InputSection(title: "차종을 선택해주세요") {
                    CustomInputBox(
                        placeholder: "대형, 준중형 등",
                        showSheet: true,
                        text: $vehicleType
                    )
                    .id(Field.carType)
                    .onTapGesture {
                        showCarTypeSheet = true
                    }
                }
            }
            
            // 4. 주행거리
            if step >= 3 {
                InputSection(title: "주행거리를 입력해주세요", subTitle: "(km)") {
                    CustomInputBox(
                        inputType: .number,
                        placeholder: "11,234km",
                        text: $vehicleMileage
                    )
                    .focused($focusedField, equals: .mileage)
                    .id(Field.mileage)
                    .onSubmit {
                        focusedField = nil
                    }
                }
            }
        }
        .onAppear {
            focusedField = .vehicleModel
        }
        .sheet(isPresented: $showCarTypeSheet) {
            CarTypeBottomSheet(
                isPresented: $showCarTypeSheet,
                selectedCarType: $selectedCarType // 단일 선택
            )
            .onDisappear {
                // 선택된 값이 있으면 vehicleType에 반영
                if let code = selectedCarType {
                    vehicleType = code
                    withAnimation(.easeInOut) {
                        step = max(step, 3)
                        focusedField = .mileage
                    }
                }
            }
            .presentationDetents([.fraction(0.4)])
        }
    }
}

struct VehicleInfoView_Previews: PreviewProvider {
    @State static var vehicleModel = ""
    @State static var year = ""
    @State static var carType = ""
    @State static var mileage = ""
    @State static var step = 0
    
    static var previews: some View {
        VehicleInfoView(
            vehicleModel: $vehicleModel,
            vehicleYear: $year,
            vehicleType: $carType,
            vehicleMileage: $mileage,
            step: $step
        )
        .previewLayout(.sizeThatFits)
    }
}
