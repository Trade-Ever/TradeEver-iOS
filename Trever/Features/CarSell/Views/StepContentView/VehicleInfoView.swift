import SwiftUI

struct VehicleInfoView: View {
    @Binding var vehicleManufacturer: String
    @Binding var vehicleModel: String
    @Binding var vehicleName: String
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
    
    // 차량 선택 플로우 시트
    @State private var showCarSelectionSheet = false
    @StateObject private var carFilter = CarFilterModel()
    
    var body: some View {
        VStack(spacing: 7) {
            // 1. 차량 모델
            if step >= 0 {
                InputSection(title: "차량 모델을 선택해주세요") {
                    CustomInputBox(
                        placeholder: "현대 아반떼 SN7",
                        showSheet: true, // 시트 표시 아이콘
                        text: .constant(displayVehicleModel) // UI 출력용
                    )
                    .onTapGesture {
                        showCarSelectionSheet = true
                    }
                }
            }
            
            // 2. 연식
            if step >= 1 {
                InputSection(title: "연식을 입력해주세요") {
                    CustomInputBox(
                        inputType: .number,
                        placeholder: "2023년",
                        text: $vehicleYear
                    )
                    .focused($focusedField, equals: .year)
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
        // 차량 선택 플로우 시트
        .fullScreenCover(isPresented: $showCarSelectionSheet) {
            CarSelectionFlowView(
                isPresented: $showCarSelectionSheet,
                filter: carFilter,
                onComplete: { filter in
                    handleCarSelectionComplete(filter)
                    
                    // 아래 처럼 코드 짜면 UI 멈춤
                    // >> 단계별 코드 처리가 필요
                    /*
                     // 선택 완료 시 차량 모델 조합
                     let modelText = formatCarModel(filter)
                     vehicleModel = modelText
                     
                     // 연식 숫자만 추출해서 저장
                     if let year = filter.carYear {
                     vehicleYear = year.replacingOccurrences(of: "년", with: "")
                     }
                     
                     // 연식 편집 가능
                     withAnimation(.easeInOut) {
                     step = max(step, 1)
                     focusedField = .year
                     }
                     
                     print("선택 완료: \(filter)")
                     */
                }
            )
        }
        // 차종 선택 시트
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
    // 표시용 텍스트 계산
    private var displayVehicleModel: String {
        var components: [String] = []
        
        if !vehicleManufacturer.isEmpty {
            components.append(vehicleManufacturer)
        }
        if !vehicleModel.isEmpty {
            components.append(vehicleModel)
        }
        if !vehicleName.isEmpty {
            components.append(vehicleName)
        }
        
        return components.isEmpty ? "" : components.joined(separator: " ")
    }
    
    // 단계별 UI 업데이트
    private func handleCarSelectionComplete(_ filter: CarFilterModel) {
        // 1단계: 먼저 시트 닫기
        showCarSelectionSheet = false
        
        // 2단계: 시트가 닫힌 후 각각 저장
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // 제조사
            if let manufacturer = filter.manufacturer {
                vehicleManufacturer = manufacturer
            }
            
            // 모델명
            if let modelName = filter.modelName {
                vehicleModel = modelName
            }
            
            // 차량명
            if let carName = filter.carName {
                vehicleName = carName
            }
            
            // 연식 (숫자만 추출)
            if let year = filter.carYear {
                vehicleYear = year.replacingOccurrences(of: "년", with: "")
            }
        }
        
        // 3단계: UI가 안정된 후 다음 단계로 이동
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.3)) {
                step = max(step, 1)
            }
            
            // 4단계: 마지막에 포커스 변경
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                focusedField = .year
            }
        }
    }
}



// 차량 선택 플로우를 담는 래퍼 뷰
struct CarSelectionFlowView: View {
    @Binding var isPresented: Bool
    @ObservedObject var filter: CarFilterModel
    let onComplete: (CarFilterModel) -> Void
    
    var body: some View {
        NavigationStack {
            ManufacturerListView(
                filter: filter,
                onComplete: { completedFilter in
                    onComplete(completedFilter)
                    isPresented = false // 시트 닫기
                }
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

struct VehicleInfoView_Previews: PreviewProvider {
    @State static var vehicleManufacturer = ""
    @State static var vehicleModel = ""
    @State static var vehicleName = ""
    @State static var year = ""
    
    @State static var carType = ""
    @State static var mileage = ""
    @State static var step = 0
    
    static var previews: some View {
        VehicleInfoView(
            vehicleManufacturer: $vehicleManufacturer,
            vehicleModel: $vehicleModel,
            vehicleName: $vehicleName,
            vehicleYear: $year,
            vehicleType: $carType,
            vehicleMileage: $mileage,
            step: $step
        )
        .previewLayout(.sizeThatFits)
    }
}
