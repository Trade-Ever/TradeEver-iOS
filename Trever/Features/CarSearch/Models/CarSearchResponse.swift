//
//  CarSearchResponse.swift
//  Trever
//
//  Created by OhChangEun on 9/23/25.
//

import Foundation

// MARK: - API 응답 모델들
struct CarSearchResponse: Codable {
    let vehicles: [Vehicle]
    let totalCount: Int
    let currentPage: Int?
    let totalPages: Int?
}

struct Vehicle: Codable, Identifiable {
    let id: Int
    let carName: String
    let carNumber: String
    let manufacturer: String
    let model: String
    let yearValue: Int
    let mileage: Int
    let transmission: String
    let vehicleStatus: String
    let fuelType: String
    let price: Int
    let isAuction: String
    let auctionId: Int
    let representativePhotoUrl: String
    let favoriteCount: Int
    let createdAt: String
    let isFavorite: Bool
    let vehicleTypeName: String
    let mainOptions: [String]
    let totalOptionsCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id, carName, carNumber, manufacturer, model, mileage
        case transmission, vehicleStatus, fuelType, price, isAuction
        case auctionId, representativePhotoUrl, favoriteCount, createdAt
        case isFavorite, vehicleTypeName, mainOptions, totalOptionsCount
        case yearValue = "year_value"
    }
}
