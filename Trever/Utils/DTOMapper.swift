import Foundation

// Map ERD DTOs to current UI models to minimize churn in Views.
enum DTOMapper {
    static func toListItem(_ v: VehicleDTO) -> CarListItem {
        CarListItem(
            id: UUID(),
            backendId: v.id,
            title: v.title,
            subTitle: v.model,
            year: v.year,
            mileageKm: v.mileage,
            thumbnailName: v.photos?.sorted(by: { ($0.order_index ?? 0) < ($1.order_index ?? 0) }).first?.photo_url,
            tags: buildTags(v),
            priceWon: v.price,
            startPrice: v.auction?.start_price ?? v.price,
            isAuction: v.is_auction,
            auctionEndsAt: v.auction?.end_at,
            likes: v.favorite_count ?? 0
        )
    }

    static func toDetail(_ v: VehicleDTO) -> CarDetail {
        let images = (v.photos ?? []).sorted(by: { ($0.order_index ?? 0) < ($1.order_index ?? 0) }).map { $0.photo_url }
        let specs: [String: String] = [
            "연료": v.fuel_type ?? "-",
            "변속기": v.transmission ?? "-",
            "배기량(cc)": v.engine_cc.map { String($0) } ?? "-",
            "마력": v.horsepower.map { "\($0)마력" } ?? "-",
            "색상": v.color ?? "-"
        ]
        return CarDetail(
            id: UUID(),
            backendId: v.id,
            title: v.title,
            subTitle: v.model,
            manufacturer: v.manufacturer,
            modelName: v.model,
            optionName: v.option_name ?? v.title,
            year: v.year,
            mileageKm: v.mileage,
            imageNames: images,
            tags: buildTags(v),
            priceWon: v.price,
            startPrice: v.auction?.start_price ?? v.price,
            likes: v.favorite_count ?? 0,
            specs: specs,
            description: v.description ?? "",
            seller: Seller(name: "판매자 #\(v.seller_id)", address: v.location_address ?? "-", createdAt: v.created_at ?? Date(), updatedAt: v.updated_at ?? Date()),
            isAuction: v.is_auction,
            auctionEndsAt: v.auction?.end_at,
            bids: (v.auction?.bids ?? []).map { BidEntry(bidderName: "사용자 #\($0.bidder_id)", priceWon: $0.bid_price, placedAt: $0.created_at) },
            isMine: false,
            potentialBuyers: v.is_auction ? nil : [
                PotentialBuyer(id: "u-1001", name: "홍길동"),
                PotentialBuyer(id: "u-2001", name: "오창운")
            ]
        )
    }

    private static func buildTags(_ v: VehicleDTO) -> [String] {
        var t: [String] = []
        if let status = v.vehicle_status { t.append(status) }
        if let fuel = v.fuel_type { t.append(fuel) }
        if let tr = v.transmission { t.append(tr) }
        return t
    }
}
