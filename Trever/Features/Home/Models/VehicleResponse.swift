//
//  VehicleResponse.swift
//  Trever
//
//  Created by 채상윤 on 9/19/25.
//

import Foundation

typealias VehiclesResponse = ApiResponse<VehiclesPage>

struct VehiclesPage: Codable {
    var vehicles: [VehicleAPIItem]
    let totalCount: Int
    let pageNumber: Int
    let pageSize: Int
}

struct VehicleAPIItem: Codable, Identifiable {
    let id: Int64
    let carName: String?
    let carNumber: String?
    let manufacturer: String?
    let model: String?
    let year_value: Int?
    let mileage: Int?
    let transmission: String?
    let vehicleStatus: String?
    let fuelType: String?
    let price: Int?
    let isAuction: String // "Y" or "N"
    let representativePhotoUrl: String?
    let locationAddress: String?
    let favoriteCount: Int?
    let createdAt: String?
    let vehicleTypeName: String?
    let mainOptions: [String]?
    let totalOptionsCount: Int?
    let auctionId: Int64?
    let startPrice: Int?
    let currentPrice: Int?
    let startAt: String?
    let endAt: String?
    let auctionStatus: String?
    let bidCount: Int?
    let isFavorite: Bool?
}
