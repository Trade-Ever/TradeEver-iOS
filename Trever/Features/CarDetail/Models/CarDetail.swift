import Foundation

// MARK: - API Response Models
struct CarDetailResponse: Codable {
    let status: Int
    let success: Bool
    let message: String
    let data: CarDetailData
}

struct CarDetailData: Codable {
    let id: Int
    let carNumber: String?
    let carName: String?
    let description: String?
    let manufacturer: String?
    let model: String?
    let yearValue: Int?
    let mileage: Int?
    let fuelType: String?
    let transmission: String?
    let accidentHistory: String?
    let accidentDescription: String?
    let engineCc: Int?
    let horsepower: Int?
    let color: String?
    let price: Int?
    let isAuction: String?
    let vehicleStatus: String?
    let auctionId: Int?
    let favoriteCount: Int?
    let createdAt: String?
    let updatedAt: String?
    let sellerId: Int?
    let sellerName: String?
    let photos: [VehiclePhoto]?
    let vehicleTypeName: String?
    let options: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id, carNumber, carName, description, manufacturer, model
        case yearValue = "year_value"
        case mileage, fuelType, transmission, accidentHistory, accidentDescription
        case engineCc = "engineCc"
        case horsepower, color, price, isAuction, vehicleStatus, auctionId
        case favoriteCount = "favoriteCount"
        case createdAt, updatedAt, sellerId, sellerName, photos, vehicleTypeName, options
    }
}

struct VehiclePhoto: Codable {
    let id: Int
    let photoUrl: String
    let orderIndex: Int
    let file: String?
}

// MARK: - UI Models (using API response directly)
typealias CarDetail = CarDetailData

struct BidEntry: Identifiable, Hashable {
    let id = UUID()
    let bidderName: String
    let priceWon: Int
    let placedAt: Date
}

struct PotentialBuyer: Identifiable, Hashable {
    let id: String
    let name: String
}
