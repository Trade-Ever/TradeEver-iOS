import Foundation

protocol VehicleService {
    func fetchBuyList() async throws -> [VehicleDTO]
    func fetchAuctionList() async throws -> [VehicleDTO]
    func fetchDetail(vehicleId: Int64) async throws -> VehicleDTO
}

final class MockVehicleService: VehicleService {
    static let shared = MockVehicleService()
    private init() {}

    func fetchBuyList() async throws -> [VehicleDTO] {
        await mockVehicles(isAuction: false)
    }

    func fetchAuctionList() async throws -> [VehicleDTO] {
        await mockVehicles(isAuction: true)
    }

    func fetchDetail(vehicleId: Int64) async throws -> VehicleDTO {
        let auctions = await mockVehicles(isAuction: true)
        let buys = await mockVehicles(isAuction: false)
        let all = auctions + buys
        return all.first { $0.id == vehicleId } ?? all[0]
    }

    // MARK: - Mock data aligned with ERD fields
    private func mockVehicles(isAuction: Bool) async -> [VehicleDTO] {
        let now = Date()

        func photos(for vehicleId: Int64) -> [VehiclePhotoDTO] {
            let urls = [
                "https://image.heydealer.com/unsafe/2250x0/https://prnd-car-purchase.s3.ap-northeast-2.amazonaws.com/media/cars/carmediafile/2025/07/24/dd095b49-f2a5-45af-83ee-179e90a3ea25.jpeg",
                "https://image.heydealer.com/unsafe/1150x0/https://prnd-car-purchase.s3.ap-northeast-2.amazonaws.com/media/cars/carmediafile/2025/07/24/1e082ccf-096d-4b7e-b6b1-4fd0112b55e2.jpeg",
                "https://image.heydealer.com/unsafe/1150x0/https://prnd-car-purchase.s3.ap-northeast-2.amazonaws.com/media/cars/carmediafile/2025/07/24/28326b8b-a951-44c6-90b8-bed12f092e7d.jpeg",
                "https://image.heydealer.com/unsafe/2250x0/https://prnd-car-purchase.s3.ap-northeast-2.amazonaws.com/media/cars/carmediafile/2025/07/24/1aa27482-50d8-4e1b-bc61-c40c685473ef.jpeg",
                "https://image.heydealer.com/unsafe/1150x0/https://prnd-car-purchase.s3.ap-northeast-2.amazonaws.com/media/cars/carmediafile/2025/07/24/17a53b68-a08f-4913-a3d2-25acc3b0a04f.jpeg"
            ]
            return urls.enumerated().map { idx, u in
                VehiclePhotoDTO(id: Int64(vehicleId * 100 + Int64(idx)), photo_url: u, order_index: idx, created_at: now, vehicle_id: vehicleId)
            }
        }

        func auction(_ vid: Int64, minutesFromNow: Int, secondsExtra: Int = 0, startOffsetMins: Int = -120, startPrice: Int) -> AuctionDTO {
            AuctionDTO(
                id: Int64(10 + vid),
                start_price: startPrice,
                buy_now_price: nil,
                start_at: now.addingTimeInterval(TimeInterval(startOffsetMins * 60)),
                end_at: now.addingTimeInterval(TimeInterval(minutesFromNow * 60 + secondsExtra)),
                status: "OPEN",
                created_at: now,
                vehicle_id: vid,
                bids: [
                    BidDTO(id: 1, bid_price: startPrice + 500_000, created_at: now.addingTimeInterval(-1800), bidder_id: 1001, auction_id: Int64(10 + vid)),
                    BidDTO(id: 2, bid_price: startPrice + 1_000_000, created_at: now.addingTimeInterval(-600), bidder_id: 1002, auction_id: Int64(10 + vid))
                ]
            )
        }

        let vehicles: [VehicleDTO] = [
            VehicleDTO(
                id: isAuction ? 101 : 1,
                title: "Torress EVX E7",
                description: "가성비 전기 SUV",
                manufacturer: "포르쉐",
                model: "Taycan",
                option_name: "GTS",
                year: 2024,
                mileage: 14800,
                fuel_type: "전기",
                transmission: "자동",
                accident_history: nil,
                accident_description: nil,
                vehicle_status: "무사고",
                engine_cc: nil,
                horsepower: 252,
                color: "화이트",
                additional_info: "파노라마 루프가 적용되어 개방감 있는 주행이 가능합니다.\n헤드업 디스플레이, 어댑티브 크루즈 컨트롤 등 주행 편의성을 더해주는 옵션들이 탑재되어 있습니다.\n보스 서라운드 사운드 시스템이 탑재되어 고품질의 음향을 즐길 수 있습니다.",
                price: 141_900_000,
                is_auction: isAuction,
                auction_id: isAuction ? 11 : nil,
                location_address: "서울",
                favorite_count: 12,
                created_at: now, updated_at: now, seller_id: 5001,
                photos: photos(for: isAuction ? 101 : 1),
                auction: isAuction ? auction(isAuction ? 101 : 1, minutesFromNow: 8, secondsExtra: 5, startOffsetMins: -120, startPrice: 140_000_000) : nil
            ),
            VehicleDTO(
                id: isAuction ? 102 : 2,
                title: "IONIQ 6",
                description: "효율적인 세단",
                manufacturer: "Hyundai",
                model: "IONIQ 6",
                option_name: "Long Range",
                year: 2023,
                mileage: 16000,
                fuel_type: "전기",
                transmission: "자동",
                accident_history: nil,
                accident_description: nil,
                vehicle_status: "1인신조",
                engine_cc: nil,
                horsepower: 228,
                color: "화이트",
                additional_info: nil,
                price: 41_900_000,
                is_auction: isAuction,
                auction_id: isAuction ? 12 : nil,
                location_address: "수원",
                favorite_count: 8,
                created_at: now, updated_at: now, seller_id: 5002,
                photos: photos(for: isAuction ? 102 : 2),
                auction: isAuction ? auction(isAuction ? 102 : 2, minutesFromNow: 25, startOffsetMins: -120, startPrice: 38_000_000) : nil
            ),
            VehicleDTO(
                id: isAuction ? 103 : 3,
                title: "G80",
                description: "고급 세단",
                manufacturer: "Genesis",
                model: "G80",
                option_name: "3.3T Sport",
                year: 2020,
                mileage: 54000,
                fuel_type: "가솔린",
                transmission: "자동",
                accident_history: nil,
                accident_description: nil,
                vehicle_status: "정비이력",
                engine_cc: 3300,
                horsepower: 370,
                color: "블랙",
                additional_info: nil,
                price: 39_500_000,
                is_auction: isAuction,
                auction_id: isAuction ? 13 : nil,
                location_address: "부산",
                favorite_count: 9,
                created_at: now, updated_at: now, seller_id: 5003,
                photos: photos(for: isAuction ? 103 : 3),
                auction: isAuction ? auction(isAuction ? 103 : 3, minutesFromNow: 180, startOffsetMins: -120, startPrice: 35_000_000) : nil
            )
        ]

        return vehicles
    }
}
