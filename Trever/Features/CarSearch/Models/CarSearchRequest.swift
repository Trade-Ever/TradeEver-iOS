//
//  CarSearchRequest.swift
//  Trever
//
//  Created by OhChangEun on 9/23/25.
//

// API 통신용 CarSearchRequest
struct CarSearchRequest: Codable {
    let keyword: String?
    let manufacturer: String?
    let carName: String?
    let carModel: String?
    let yearStart: Int?
    let yearEnd: Int?
    let mileageStart: Int?
    let mileageEnd: Int?
    let priceStart: Int?
    let priceEnd: Int?
    let vehicleType: String?
    var page: Int
    var size: Int
}
