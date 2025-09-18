//
//  SellCarModel.swift
//  Trever
//
//  Created by OhChangEun on 9/17/25.
//

import Foundation
import SwiftUI

class SellCarModel: ObservableObject {
    // Step0: 차량 번호
    @Published var vehicleNumber: String = ""

    // Step1: 차량 정보
    @Published var vehicleModel: String = ""
    @Published var vehicleYear: String = ""
    @Published var vehicleType: String = ""
    @Published var vehicleMileage: String = ""
    
    // Step2: 엔진 정보
    @Published var fuelType: String = ""
    @Published var transmission: String = ""
    @Published var displacement: String = ""
    @Published var horsepower: String = ""

    // Step3: 차량 이미지와 색상
    @Published var selectedImagesData: [Data] = []
    @Published var vehicleColor: String = ""

    // Step4: 차량 옵션 및 상세 설명
    @Published var vehicleOptions: String = ""
    @Published var detailedDescription: String = ""

    // Step5: 사고/추가 정보
    @Published var accidentHistory: String = ""
    @Published var accidentDescription: String = ""
    
    // Step6: 거래 정보
    @Published var tradeMethod: String = ""
    @Published var startDate: Date? = nil
    @Published var endDate: Date? = nil
    @Published var price: String = ""
}


