//
//  CarSearchResponse.swift
//  Trever
//
//  Created by OhChangEun on 9/23/25.
//

import Foundation

// MARK: - Vehicle Search Response
struct VehicleResponse: Codable {
    let vehicles: [Vehicle]
    let totalCount: Int
    let pageNumber: Int
    let pageSize: Int
}

struct Pageable: Codable {
    let pageNumber: Int
    let pageSize: Int
    let sort: Sort
    let offset: Int
    let paged: Bool
    let unpaged: Bool
}

struct Sort: Codable {
    let empty: Bool
    let sorted: Bool
    let unsorted: Bool
}

// MARK: - Vehicle Model
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
    let price: Int?
    let isAuction: String
    let auctionId: Int?
    let representativePhotoUrl: String?
    let favoriteCount: Int
    let createdAt: String
    let isFavorite: Bool
    let vehicleTypeName: String
    let mainOptions: [String]
    let totalOptionsCount: Int
    
    private enum CodingKeys: String, CodingKey {
        case id, carName, carNumber, manufacturer, model, mileage, transmission, vehicleStatus, fuelType, price, isAuction, auctionId, representativePhotoUrl, favoriteCount, createdAt, isFavorite, vehicleTypeName, mainOptions, totalOptionsCount
        case yearValue = "year_value"
    }
}

