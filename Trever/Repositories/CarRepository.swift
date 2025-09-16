import Foundation

enum CarRepository {
    static var sampleBuyList: [CarListItem] {
        [
            CarListItem(
                id: UUID(),
                title: "Torress EVX E7",
                subTitle: nil,
                year: 2024,
                mileageKm: 38000,
                thumbnailName: "Car Item",
                tags: ["비흡연자", "무사고", "정비이력"],
                priceWon: 33_000_000,
                isAuction: false,
                auctionEndsAt: nil,
                likes: 12
            ),
            CarListItem(
                id: UUID(),
                title: "IONIQ 6",
                subTitle: nil,
                year: 2023,
                mileageKm: 16000,
                thumbnailName: "Car Item1",
                tags: ["1인신조", "완전무사고"],
                priceWon: 41_900_000,
                isAuction: false,
                auctionEndsAt: nil,
                likes: 8
            )
        ]
    }

    static var sampleAuctionList: [CarListItem] {
        [
            CarListItem(
                id: UUID(),
                title: "Taycan",
                subTitle: "AWD",
                year: 2024,
                mileageKm: 16000,
                thumbnailName: "Car Item1",
                tags: ["비흡연자", "무사고", "정비이력"],
                priceWon: 141_900_000,
                isAuction: true,
                auctionEndsAt: Date().addingTimeInterval(60*4),
                likes: 32
            ),
            CarListItem(
                id: UUID(),
                title: "Model X",
                subTitle: "AWD",
                year: 2024,
                mileageKm: 38000,
                thumbnailName: "Car Item",
                tags: ["비흡연자", "정비이력"],
                priceWon: 125_000_000,
                isAuction: true,
                auctionEndsAt: Date().addingTimeInterval(60*75),
                likes: 20
            )
        ]
    }

    static func mockDetail(for id: UUID) -> CarDetail {
        // In a real app, fetch by id; here, return a composed mock
        let imageNames = [
            "https://image.heydealer.com/unsafe/1400x0/https://prnd-car-purchase.s3.ap-northeast-2.amazonaws.com/media/cars/liveview/2025/09/11/9fc75878-f0e4-4d69-b9a0-36f6f131aa13.png",
            "https://image.heydealer.com/unsafe/1400x0/https://prnd-car-purchase.s3.ap-northeast-2.amazonaws.com/media/cars/liveview/2025/09/11/9fc75878-f0e4-4d69-b9a0-36f6f131aa13.png"
        ]
        return CarDetail(
            id: id,
            title: "테슬라 Model X",
            subTitle: "AWD",
            year: 2024,
            mileageKm: 38000,
            imageNames: imageNames,
            tags: ["비흡연자", "무사고", "정비이력"],
            priceWon: 125_000_000,
            likes: 32,
            specs: [
                "연료": "전기",
                "변속기": "자동",
                "배기량(cc)": "해당없음",
                "마력": "252마력",
                "색상": "미드나잇 실버",
                "기타 정보": "열선시트(앞좌석)"
            ],
            description: "2열 캡틴 시트가 장착된 6인승 차량입니다.\n\nFSD(Full Self Driving) 옵션이 탑재된 차량입니다.\n\n열선 핸들, 열선 시트(1열 및 2열), 통풍 시트(1열)가 탑재되어 쾌적한 주행이 가능한 차량입니다.",
            seller: Seller(
                name: "홍길동",
                address: "경기도 수원시",
                createdAt: ISO8601DateFormatter().date(from: "2025-09-12T10:00:00Z") ?? Date(),
                updatedAt: ISO8601DateFormatter().date(from: "2025-09-15T10:00:00Z") ?? Date()
            ),
            isAuction: true,
            auctionEndsAt: Date().addingTimeInterval(60 * 75),
            bids: mockBids(for: id)
        )
    }

    static func mockDetail(from item: CarListItem) -> CarDetail {
        let imageNames = [
            "https://image.heydealer.com/unsafe/1400x0/https://prnd-car-purchase.s3.ap-northeast-2.amazonaws.com/media/cars/liveview/2025/09/11/9fc75878-f0e4-4d69-b9a0-36f6f131aa13.png",
            "https://image.heydealer.com/unsafe/1400x0/https://prnd-car-purchase.s3.ap-northeast-2.amazonaws.com/media/cars/liveview/2025/09/11/9fc75878-f0e4-4d69-b9a0-36f6f131aa13.png"
        ]
        return CarDetail(
            id: item.id,
            title: item.title,
            subTitle: item.subTitle,
            year: item.year,
            mileageKm: item.mileageKm,
            imageNames: imageNames,
            tags: item.tags,
            priceWon: item.priceWon,
            likes: item.likes,
            specs: [
                "연료": "전기",
                "변속기": "자동",
                "배기량(cc)": "해당없음",
                "마력": "252마력",
                "색상": "미드나잇 실버",
                "기타 정보": "열선시트(앞좌석)"
            ],
            description: "2열 캡틴 시트가 장착된 6인승 차량입니다.\n\nFSD(Full Self Driving) 옵션이 탑재된 차량입니다.\n\n열선 핸들, 열선 시트(1열 및 2열), 통풍 시트(1열)가 탑재되어 쾌적한 주행이 가능한 차량입니다.",
            seller: Seller(
                name: "홍길동",
                address: "경기도 수원시",
                createdAt: ISO8601DateFormatter().date(from: "2025-09-12T10:00:00Z") ?? Date(),
                updatedAt: ISO8601DateFormatter().date(from: "2025-09-15T10:00:00Z") ?? Date()
            ),
            isAuction: item.isAuction,
            auctionEndsAt: item.auctionEndsAt,
            bids: item.isAuction ? mockBids(for: item.id) : []
        )
    }

    static func mockBids(for id: UUID) -> [BidEntry] {
        let base = Date().addingTimeInterval(-60*60)
        return [
            BidEntry(bidderName: "홍길동", priceWon: 125_000_000, placedAt: base.addingTimeInterval(60*45)),
            BidEntry(bidderName: "오창운", priceWon: 120_000_000, placedAt: base.addingTimeInterval(60*30)),
            BidEntry(bidderName: "채상윤", priceWon: 110_000_000, placedAt: base.addingTimeInterval(60*15)),
            BidEntry(bidderName: "홍길동", priceWon: 105_000_000, placedAt: base.addingTimeInterval(60*10)),
            BidEntry(bidderName: "오창운", priceWon: 100_000_000, placedAt: base.addingTimeInterval(60*5))
        ]
        .sorted(by: { $0.placedAt > $1.placedAt })
    }
}
