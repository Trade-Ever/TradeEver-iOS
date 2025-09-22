//
//  CarSearchModels.swift
//  Trever
//
//  Created by OhChangEun on 9/22/25.
//

import Foundation

struct CarSearchFilter {
    var manufacturer: String = "제조사 • 모델"
    var year: String = "1998년 ~ 2025년"
    var mileage: String = "0km ~ 30만km"
    var price: String = "1000만원 ~ 30억원"
    var vehicleType: String = "SUV"
}

struct RecentSearch {
    let id = UUID()
    let term: String
}
