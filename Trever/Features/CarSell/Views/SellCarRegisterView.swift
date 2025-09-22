//
//  SellCarView.swift
//  Trever
//
//  Created by OhChangEun on 9/16/25.
//

import SwiftUI

struct SellCarRegisterView: View {
    @State private var currentStep: Int = 0 // 현재 단계
    @State private var showExitAlert = false // 화면 나가기 클릭 시 상태
    @State private var showRegisterAlert = false // 차량 등록 시 표시 상태
    @State private var showSuccessAlert = false // 등록 완료 알림 상태
    @State private var registrationSuccess = false // 등록 성공 여부
    
    @StateObject private var viewModel = SellCarViewModel()
    @StateObject private var keyboard = KeyboardState()
    
    private let tabBarHeight: CGFloat = 66
    let totalSteps = 7
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Step Bar
                    StepBarView(currentStep: $currentStep, totalSteps: totalSteps)
                        .padding(.top, 40)
                        .padding(.bottom, 24)
                    
                    // 현재 페이지 내용
                    Group {
                        switch currentStep {
                        case 0: // 차량 번호
                            VehicleNumberView(
                                vehicleNumber: $viewModel.model.vehicleNumber,
                            )
                        case 1: // 차량 정보
                            VehicleInfoView(
                                vehicleManufacturer: $viewModel.model.vehicleManufacturer,
                                vehicleModel: $viewModel.model.vehicleModel,
                                vehicleName: $viewModel.model.vehicleName,
                                vehicleYear: $viewModel.model.vehicleYear,
                                vehicleType: $viewModel.model.vehicleType,
                                vehicleMileage: $viewModel.model.vehicleMileage,
                                step: $viewModel.vehicleInfoStep
                            )
                        case 2: // 엔진 정보
                            EngineInfoView(
                                fuelType: $viewModel.model.fuelType,
                                transmission: $viewModel.model.transmission,
                                displacement: $viewModel.model.displacement,
                                horsepower: $viewModel.model.horsepower,
                                step: $viewModel.engineInfoStep
                            )
                        case 3: // 이미지 정보
                            ImageUploadView(
                                vehicleColor: $viewModel.model.vehicleColor,
                                selectedImagesData: $viewModel.model.selectedImagesData,
                                step: $viewModel.imageUploadStep
                            )
                        case 4: // 차량 옵션
                            VehicleOptionView(
                                vehicleOptions: $viewModel.model.vehicleOptions,
                                detailedDescription: $viewModel.model.detailedDescription,
                                step: $viewModel.vehicleOptionStep
                            )
                        case 5: // 사고 정보 
                            AccidentInfoView(
                                accidentHistory: $viewModel.model.accidentHistory,
                                accidentDescription: $viewModel.model.accidentDescription,
                                step: $viewModel.accidentInfoStep
                            )
                        case 6: // 거래 정보
                            TradeInfoView(
                                tradeMethod: $viewModel.model.tradeMethod,
                                startDate: $viewModel.model.startDate,
                                endDate: $viewModel.model.endDate,
                                price: $viewModel.model.price,
                                step: $viewModel.tradeInfoStep
                            )
                        default:
                            Text("Unknown Page")
                        }
                    }
                    .animation(.easeInOut, value: currentStep)
                    .frame(maxWidth: .infinity, alignment: .top)
                    .padding(.top, 8)
                    
                    Spacer(minLength: 80) // 하단 바 영역 여유
                }
            }
            // 키보드가 있을 때, 입력 필드를 조금 더 띄우기 위한 추가 여백
            .safeAreaInset(edge: .bottom) {
                if keyboard.isVisible { Color.clear.frame(height: 16) }
            }
            // 하단 버튼을 키보드 위로 고정
            .safeAreaInset(edge: .bottom) {
                StepActionBar(
                    currentStep: currentStep,
                    totalSteps: totalSteps,
                    onNext: {
                        if currentStep == totalSteps - 1 {
                            // 등록 버튼 클릭 시 alert 표시
                            showRegisterAlert = true
                        } else {
                            DispatchQueue.main.async {
                                currentStep = min(currentStep + 1, totalSteps - 1)
                            }
                            // currentStep = min(currentStep + 1, totalSteps - 1)
                            // 뷰가 업데이트되는 동안(@State/ObservableObject 변경) 다시 상태를 바꾸려고 해서 SwiftUI가 경고를 내는 상황
                            // SwiftUI 뷰의 body가 다시 그려지는 동안(View 업데이트 중)에 @Published나 @State 같은 상태를 동기적으로 변경했을 때 발생하는 오류.
                        }
                    },
                    onPrevious: { currentStep = max(currentStep - 1, 0) },
                    isStepCompleted: { viewModel.isStepCompleted(currentStep: $0) }
                )
            }
            .navigationBarTitleDisplayMode(.inline)
            .scrollDismissesKeyboard(.interactively)
            .navigationBarBackButtonHidden(true) // 기본 Back 숨기기
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showExitAlert = true
                    }) {
                        HStack (spacing: 4) {
                            Image(systemName: "arrow.left")
                                .foregroundStyle(Color.errorRed)
                            Text("나가기")
                                .foregroundStyle(Color.errorRed)
                                .bold()
                        }
                    }
                }
            }
            .alert("정말 나가시겠습니까?", isPresented: $showExitAlert) {
                Button("취소", role: .cancel) { }
                Button("나가기", role: .destructive) {
                    dismiss()
                }
            } message: {
                Text("입력한 차량 등록 정보가 사라집니다.")
            }
            .alert("차량 등록", isPresented: $showRegisterAlert) {
                Button("취소", role: .cancel) { }
                Button("등록") {
                    Task {
                        let success = await viewModel.registerVehicle()
                        registrationSuccess = success
                        showSuccessAlert = true
                    }
                }
            } message: {
                Text("차량을 등록하시겠습니까?")
            }
            // 등록 완료 알림
            .alert(registrationSuccess ? "등록 완료" : "등록 실패",
                   isPresented: $showSuccessAlert) {
                Button("확인") {
                    if registrationSuccess {
                        dismiss() // 성공시 화면 닫기
                    }
                }
            } message: {
                Text(registrationSuccess ?
                     "차량이 성공적으로 등록되었습니다." :
                     "차량 등록에 실패했습니다. 다시 시도해주세요.")
            }
        }
    }
}

struct SellCarRegisterView_Previews: PreviewProvider {
    static var previews: some View {
        SellCarRegisterView()
    }
}
