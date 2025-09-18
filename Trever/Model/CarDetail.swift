import Foundation

struct Seller: Hashable {
    let name: String
    let address: String
    let createdAt: Date
    let updatedAt: Date
}

struct BidEntry: Identifiable, Hashable {
    let id = UUID()
    let bidderName: String
    let priceWon: Int
    let placedAt: Date
}

struct CarDetail: Identifiable, Hashable {
    let id: UUID
    let backendId: Int64?
    let title: String
    let subTitle: String?
    // ERD 기반 명칭
    let manufacturer: String?
    let modelName: String?
    let optionName: String?
    let year: Int
    let mileageKm: Int
    let imageNames: [String] // placeholder for URLs later
    let tags: [String]
    let priceWon: Int
    let startPrice: Int
    let likes: Int

    // Specs and description
    let specs: [String: String]
    let description: String

    // Seller
    let seller: Seller

    // Auction
    let isAuction: Bool
    let auctionEndsAt: Date?
    let bids: [BidEntry]

    // Ownership
    let isMine: Bool

    // Potential buyers for direct sale completion (non-auction)
    let potentialBuyers: [PotentialBuyer]?
}

struct PotentialBuyer: Identifiable, Hashable {
    let id: String
    let name: String
}
