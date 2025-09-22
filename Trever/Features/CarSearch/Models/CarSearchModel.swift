//
//  CarSearchModels.swift
//  Trever
//
//  Created by OhChangEun on 9/22/25.
//

import Foundation

struct CarSearchFilter {
    var manufacturer: String = "전체"
    var year: String = "전체"
    var mileage: String = "전체"
    var price: String = "전체"
    var vehicleType: String = "전체"
}

// 최근 검색어 모델 예시
struct RecentSearch: Decodable {
    let id: Int
    let keyword: String
    let createdAt: String
}

struct CarSearchModel {
    var keyword: String?
    var manufacturer: String?
    var carName: String?
    var carModel: String?
    var yearStart: Int?
    var yearEnd: Int?
    var mileageStart: Int? // 만km 단위
    var mileageEnd: Int?   // 만km 단위
    var priceStart: Int?   // 천만원 단위
    var priceEnd: Int?     // 천만원 단위
    var vehicleType: String?
    
    // 초기화
    init() {
        self.keyword = nil
        self.manufacturer = nil
        self.carName = nil
        self.carModel = nil
        self.yearStart = nil
        self.yearEnd = nil
        self.mileageStart = nil
        self.mileageEnd = nil
        self.priceStart = nil
        self.priceEnd = nil
        self.vehicleType = nil
    }
}
