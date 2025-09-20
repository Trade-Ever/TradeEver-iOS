import Foundation

struct CarListItem: Identifiable, Hashable {
    let id: UUID
    let backendId: Int?
    let title: String
    let subTitle: String?
    let year: Int
    let mileageKm: Int
    let thumbnailName: String? // placeholder for image URL later
    let tags: [String]
    let priceWon: Int
    let startPrice: Int
    let isAuction: Bool
    let auctionEndsAt: Date?
    let likes: Int
}
