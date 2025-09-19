//
//  Untitled.swift
//  Trever
//
//  Created by OhChangEun on 9/18/25.
//

/*
import Foundation

struct SellCarRequest: Encodable {
    let carNumber: String          // 차량 번호
    
    let carName: String            // 차량 이름 (예: 현대 아반떼 CN7)
    let description: String        // 설명
    
    let manufacturer: String       // 제조사
    let model: String              // 모델명
    let year_value: Int            // 연식
    let mileage: Int               // 주행거리
    
    let fuelType: String           // 연료
    let transmission: String       // 변속기
    let accidentHistory: Bool      // 사고 이력
    let accidentDescription: String// 사고 설명
    let vehicleStatus: String      // 차량 상태 (예: ACTIVE)
    
    let engineCc: Int              // 배기량
    let horsepower: Int            // 마력
    let color: String              // 색상
    let additionalInfo: String     // 추가정보
    
    let isAuction: Bool            // 경매 여부
    let price: Int                 // 가격
    let locationAddress: String    // 위치 주소
    
    let photoOrders: [Int]         // 사진 순서
    let vehicleType: String        // 차량 타입
    let options: [String]          // 차량 옵션
}

extension SellCarRequest {
    init(from model: SellCarModel) {
        self.carNumber = model.vehicleNumber
        
        self.carName = model.vehicleModel
        self.manufacturer = "현대"   // ❗️추가 입력 받아야 함
        self.model = model.vehicleModel
        self.year_value = Int(model.vehicleYear) ?? 0
        
        // 한글 → 영문 매핑
        let vehicleTypeMapping: [String: String] = [
            "대형": "LARGE",
            "중형": "MID_SIZE",
            "준중형": "SEMI_MID_SIZE",
            "소형": "SMALL",
            "스포츠": "SPORTS",
            "SUV": "SUV",
            "승합차": "VAN",
            "경차": "COMPACT"
        ]
        self.vehicleType = vehicleTypeMapping[model.vehicleType] ?? "UNKNOWN"
        self.mileage = Int(model.vehicleMileage) ?? 0
        
        self.fuelType = model.fuelType
        self.transmission = model.transmission
        self.engineCc = Int(model.displacement) ?? 0
        self.horsepower = Int(model.horsepower) ?? 0
        
        self.photoOrders = Array(0..<model.selectedImagesData.count)
        self.color = model.vehicleColor
        
        self.options = model.vehicleOptions.split(separator: ",").map { String($0) }
        self.description = model.detailedDescription
        
        self.accidentHistory = (model.accidentHistory == "Y")
        self.accidentDescription = model.accidentDescription

        self.isAuction = model.tradeMethod == "경매" ? true : false
        self.price = Int(model.price) ?? 0
        
        
        
//
//        
//        
//        self.vehicleStatus = "ACTIVE"
//        self.additionalInfo = ""   // ❗️추가 입력 필요 시
//        self.locationAddress = "서울특별시 강남구 테헤란로 152" // ❗️추가 입력 필요 시
    }
}
 */

import Foundation

struct SellCarRequest: Codable {
    var carNumber: String
    var carName: String
    var manufacturer: String
    var vehicleType: String
    var year_value: String
    var mileage: Int
    var fuelType: String
    var transmission: String
    var engineCc: Int
    var horsepower: Int
    var color: String
    var options: [String]
    var description: String
    var accidentHistory: Bool
    var accidentDescription: String?
    
    var isAuction: Bool
    var startAt: String?
    var endAt: String?
    var price: Int?
    var startPrice: Int?

    // 한글 → 영문 매핑
    private let vehicleTypeMapping: [String: String] = [
        "대형": "LARGE",
        "중형": "MID_SIZE",
        "준중형": "SEMI_MID_SIZE",
        "소형": "SMALL",
        "스포츠": "SPORTS",
        "SUV": "SUV",
        "승합차": "VAN",
        "경차": "COMPACT"
    ]
    
    init(from model: SellCarModel) {
        // 옵션 배열 처리
        let optionsArray = model.vehicleOptions
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        // 날짜 포맷
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // 차량 타입 매핑
        let mappedVehicleType = vehicleTypeMapping[model.vehicleType] ?? model.vehicleType
        
        self.carNumber = model.vehicleNumber
        self.carName = model.vehicleModel
        self.manufacturer = model.vehicleModel
        self.vehicleType = mappedVehicleType
        self.year_value = model.vehicleYear
        self.mileage = Int(model.vehicleMileage) ?? 0
        self.fuelType = model.fuelType
        self.transmission = model.transmission
        self.engineCc = Int(model.displacement) ?? 0
        self.horsepower = Int(model.horsepower) ?? 0
        self.color = model.vehicleColor
        self.options = optionsArray
        self.description = model.detailedDescription
        self.accidentHistory = model.accidentHistory == "있음"
        self.accidentDescription = model.accidentDescription
        
        // 거래 방식에 따라 isAuction, start/end, price 처리
        if model.tradeMethod == "경매" {
            self.isAuction = true
            self.startPrice = Int(model.price) ?? 0
            self.startAt = model.startDate != nil ? dateFormatter.string(from: model.startDate!) : nil
            self.endAt = model.endDate != nil ? dateFormatter.string(from: model.endDate!) : nil
            self.price = nil
        } else {
            self.isAuction = false
            self.startPrice = nil
            self.startAt = nil
            self.endAt = nil
            self.price = Int(model.price) ?? 0
        }
    }
}


