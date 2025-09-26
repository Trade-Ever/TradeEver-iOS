import Foundation

// MARK: - ERD-aligned DTOs (Codable)

struct VehicleDTO: Codable, Identifiable {
    let id: Int64
    let title: String
    let description: String?
    let manufacturer: String?
    let model: String?
    let option_name: String?
    let year: Int
    let mileage: Int
    let fuel_type: String?
    let transmission: String?
    let accident_history: String?
    let accident_description: String?
    let vehicle_status: String?
    let engine_cc: Int?
    let horsepower: Int?
    let color: String?
    let additional_info: String?
    let price: Int
    let is_auction: Bool
    let auction_id: Int64?
    let location_address: String?
    let favorite_count: Int?
    let created_at: Date?
    let updated_at: Date?
    let seller_id: Int64
    let photos: [VehiclePhotoDTO]?
    let auction: AuctionDTO?
}

struct VehiclePhotoDTO: Codable, Identifiable {
    let id: Int64
    let photo_url: String
    let order_index: Int?
    let created_at: Date?
    let vehicle_id: Int64
}

struct AuctionDTO: Codable, Identifiable {
    let id: Int64
    let start_price: Int
    let buy_now_price: Int?
    let start_at: Date
    let end_at: Date
    let status: String?
    let created_at: Date?
    let vehicle_id: Int64
    let bids: [BidDTO]?
}

struct BidDTO: Codable, Identifiable {
    let id: Int64
    let bid_price: Int
    let created_at: Date
    let bidder_id: Int64
    let auction_id: Int64
}

