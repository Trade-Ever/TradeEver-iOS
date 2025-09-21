//
//  Untitled.swift
//  Trever
//
//  Created by OhChangEun on 9/18/25.
//

import Foundation

struct SellCarRequest: Codable {
    var carNumber: String
    
    var manufacturer: String            // 제조사
    var model: String                   // 차량 모델
    var carName: String                 // 차량 이름
    var year_value: Int?                // 연식

    var vehicleType: String             // 차량 종류
    var mileage: Int?                   // 주행 거리
    
    var fuelType: String                // 연료
    var transmission: String            // 변속기
    var engineCc: Int                   // 배기량
    var horsepower: Int                 // 마력
    
    var color: String                   // 차량 색상
    
    var options: [String]               // 차량 옵션
    var description: String             // 상세 설명
    var accidentHistory: Bool           // 사고 유무
    var accidentDescription: String?    // 사고 설명
    
    var isAuction: Bool                 // 경매 유무(true: 경매, false: 일반거래)
    var startAt: String?                // 경매 시작날짜
    var endAt: String?                  // 경매 종료날짜
    var price: Int?                     // 가격(일반거래)
    var startPrice: Int?                // 가격(경매)

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
    
    init(from sellCarModel: SellCarModel) {
        // 옵션 배열 처리
        let optionsArray = sellCarModel.vehicleOptions
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        // 날짜 포맷
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // 차량 타입 매핑
        let mappedVehicleType = vehicleTypeMapping[sellCarModel.vehicleType] ?? sellCarModel.vehicleType
        
        self.carNumber = sellCarModel.vehicleNumber

        self.manufacturer = sellCarModel.vehicleManufacturer
        self.model = sellCarModel.vehicleModel
        self.carName = sellCarModel.vehicleName
        self.year_value = Int(sellCarModel.vehicleYear) ?? 0
        
        self.vehicleType = mappedVehicleType
        self.mileage = Int(sellCarModel.vehicleMileage) ?? 0

        self.fuelType = sellCarModel.fuelType
        self.transmission = sellCarModel.transmission
        self.engineCc = Int(sellCarModel.displacement) ?? 0
        self.horsepower = Int(sellCarModel.horsepower) ?? 0
        
        self.color = sellCarModel.vehicleColor
        
        self.options = optionsArray
        self.description = sellCarModel.detailedDescription
        
        self.accidentHistory = sellCarModel.accidentHistory == "있음"
        self.accidentDescription = sellCarModel.accidentDescription
        
        // 거래 방식에 따라 isAuction, start/end, price 처리
        // 경매: startPrice, 날짜 입력
        // 일반거래: price, 날짜 입력x
        if sellCarModel.tradeMethod == "경매" {
            self.isAuction = true
            self.startPrice = (Int(sellCarModel.price) ?? 0) * 10000 // 만원 단위
            self.startAt = sellCarModel.startDate != nil ? dateFormatter.string(from: sellCarModel.startDate!) : nil
            self.endAt = sellCarModel.endDate != nil ? dateFormatter.string(from: sellCarModel.endDate!) : nil
            self.price = nil
        } else {
            self.isAuction = false
            self.startPrice = nil
            self.startAt = nil
            self.endAt = nil
            self.price = (Int(sellCarModel.price) ?? 0) * 10000 // 만원 단위
        }
    }
}


