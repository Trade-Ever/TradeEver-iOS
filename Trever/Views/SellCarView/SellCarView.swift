//
//  SellCarView.swift
//  Trever
//
//  Created by OhChangEun on 9/16/25.
//

import SwiftUI

struct SellCarView: View {
    @State private var currentStep: Int = 0
    @StateObject private var viewModel = SellCarViewModel()
    private let tabBarHeight: CGFloat = 66 // CustomTabBar height to avoid overlap
    @StateObject private var keyboard = KeyboardState()
    
    let totalSteps = 7
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView { // 내용이 길면 스크롤 가능
                VStack(alignment: .leading, spacing: 0) {
                    // Step Bar
                    StepBarView(currentStep: $currentStep, totalSteps: totalSteps)
                        .padding(.top, 40)
                        .padding(.bottom, 24)

                    // 현재 페이지 내용
                    Group {
                        switch currentStep {
                        case 0:
                            VehicleNumberView(
                                vehicleNumber: $viewModel.model.vehicleNumber,
                            )
                        case 1:
                            VehicleInfoView(
                                vehicleModel: $viewModel.model.vehicleModel,
                                vehicleYear: $viewModel.model.vehicleYear,
                                vehicleType: $viewModel.model.vehicleType,
                                vehicleMileage: $viewModel.model.vehicleMileage,
                                step: $viewModel.vehicleInfoStep
                            )
                        case 2:
                            EngineInfoView(
                                fuelType: $viewModel.model.fuelType,
                                transmission: $viewModel.model.transmission,
                                displacement: $viewModel.model.displacement,
                                horsepower: $viewModel.model.horsepower,
                                step: $viewModel.engineInfoStep
                            )
                        case 3:
                            ImageUploadView(
                                vehicleColor: $viewModel.model.vehicleColor,
                                selectedImagesData: $viewModel.model.selectedImagesData,
                                step: $viewModel.imageUploadStep
                            )
                        case 4:
                            VehicleOptionView(
                                vehicleOptions: $viewModel.model.vehicleOptions,
                                detailedDescription: $viewModel.model.detailedDescription,
                                step: $viewModel.vehicleOptionStep
                            )
                        case 5:
                            AccidentInfoView(
                                accidentHistory: $viewModel.model.accidentHistory,
                                accidentDescription: $viewModel.model.accidentDescription,
                                step: $viewModel.accidentInfoStep
                            )
                        case 6:
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
                    .padding(.horizontal)

                    Spacer(minLength: 80) // 하단 바 영역 여유
                }
            }
            // 키보드가 있을 때, 입력 필드를 조금 더 띄우기 위한 추가 여백
            .safeAreaInset(edge: .bottom) {
                if keyboard.isVisible { Color.clear.frame(height: 28) }
            }
            // 하단 버튼을 키보드 위로 고정
            .safeAreaInset(edge: .bottom) { bottomActionBar }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .scrollDismissesKeyboard(.interactively)
        }
    }

    private var bottomActionBar: some View {
        HStack(spacing: 16) {
            if currentStep > 0 {
                PrimaryButton(
                    title: "이전",
                    action: { currentStep = max(currentStep - 1, 0) },
                    isOutline: true
                )
                .frame(width: 120)
            }

            PrimaryButton(
                title: currentStep == totalSteps - 1 ? "등록하기" : "다음",
                action: { currentStep = min(currentStep + 1, totalSteps - 1) }
            )
            .frame(maxWidth: .infinity)
            .opacity(viewModel.isStepCompleted(currentStep: currentStep) ? 1.0 : 0.5)
            .disabled(!viewModel.isStepCompleted(currentStep: currentStep))
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial) // 키보드 올라와도 위에 고정
    }
}

struct SellCarView_Previews: PreviewProvider {
    static var previews: some View {
        SellCarView()
    }
}
