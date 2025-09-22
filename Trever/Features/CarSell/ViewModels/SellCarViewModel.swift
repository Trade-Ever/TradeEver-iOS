//
//  SellCarViewModel.swift
//  Trever
//
//  Created by OhChangEun on 9/17/25.
//

import SwiftUI

class SellCarViewModel: ObservableObject {
    @Published var model = SellCarModel()
    
    // 각 페이지별 step
    @Published var vehicleInfoStep: Int = 0
    @Published var engineInfoStep: Int = 0
    @Published var imageUploadStep: Int = 0
    @Published var vehicleOptionStep: Int = 0
    @Published var accidentInfoStep: Int = 0
    @Published var tradeInfoStep: Int = 0
    
    // 페이지별 완료 조건
    var isVehicleNumberCompleted: Bool { model.vehicleNumber.count >= 6 }
    var isVehicleInfoCompleted: Bool { vehicleInfoStep >= 3 && model.vehicleMileage.count >= 1 }
    var isEngineInfoCompleted: Bool { engineInfoStep >= 3 && model.horsepower.count >= 1}
    var isImageUploadCompleted: Bool { imageUploadStep >= 1 && model.vehicleColor.count >= 1 }
    var isVehicleOptionCompleted: Bool { vehicleOptionStep >= 1 }
    var isAccidentInfoCompleted: Bool { model.accidentHistory == "없음" || (accidentInfoStep >= 1 && model.accidentDescription.count >= 1) }
    var isTradeInfoCompleted: Bool { tradeInfoStep >= 2 && model.price.count >= 2}
    
    // 페이지별 완료 여부 계산
    func isStepCompleted(currentStep: Int) -> Bool {
        switch currentStep {
        case 0: return isVehicleNumberCompleted
        case 1: return isVehicleInfoCompleted
        case 2: return isEngineInfoCompleted
        case 3: return isImageUploadCompleted
        case 4: return isVehicleOptionCompleted
        case 5: return isAccidentInfoCompleted
        case 6: return isTradeInfoCompleted
        default: return false
        }
    }
    
    // 전체 입력 유효성 검사
    func isStepValid(step: Int) -> Bool {
        switch step {
        case 0: return !model.vehicleNumber.isEmpty
        case 1: return !model.vehicleModel.isEmpty
        case 2: return !model.fuelType.isEmpty
        default: return true
        }
    }
    
    func registerVehicle() async -> Bool {
        do {
            let request = SellCarRequest(from: model)
            let imagesData = model.selectedImagesData

            let apiResponse: ApiResponse<Int> = try await NetworkManager.shared.upload(
                to: .vehicles,
                request: request,
                imagesData: imagesData,
                responseType: ApiResponse<Int>.self
            )

            if apiResponse.success {
                return true
            } else {
                return false
            }
        } catch {
            print("차량 등록 실패: \(error.localizedDescription)")
            return false
        }
    }
}
