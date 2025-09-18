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
    
    let totalSteps = 7
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                // Step Bar
                StepBarView(currentStep: $currentStep, totalSteps: totalSteps)
                    .padding(.top, 40)
                
                Spacer()
                
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
                        
                    default: Text("Unknown Page")
                    }
                }
                .animation(.easeInOut, value: currentStep)
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(.top, 40)
                
                Spacer()
                
                //                if viewModel.isStepCompleted(currentStep: currentStep) {
                //                }
                // 다음 버튼 - 입력을 모두 마쳤을 때
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
                    .opacity(viewModel.isStepCompleted(currentStep: currentStep) ? 1.0 : 0.5) // 완료 안되면 반투명
                    .disabled(!viewModel.isStepCompleted(currentStep: currentStep)) // 완료 안되면 클릭 불가
                }
                .padding()
                .padding(.bottom, 16)
            }
        }
        .navigationTitle("") // 타이틀 숨기기
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SellCarView_Previews: PreviewProvider {
    static var previews: some View {
        SellCarView()
    }
}
