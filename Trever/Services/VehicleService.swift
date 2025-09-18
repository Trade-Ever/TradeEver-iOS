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

        func photos1(for vehicleId: Int64) -> [VehiclePhotoDTO] {
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
        
        func photos2(for vehicleId: Int64) -> [VehiclePhotoDTO] {
            let urls = [
                "https://image.heydealer.com/unsafe/2250x0/https://prnd-car-purchase.s3.ap-northeast-2.amazonaws.com/media/cars/carmediafile/2024/11/29/097ad1f4-807a-45aa-ba98-535471ab7bec.JPEG",
                "https://image.heydealer.com/unsafe/1150x0/https://prnd-car-purchase.s3.ap-northeast-2.amazonaws.com/media/cars/carmediafile/2024/11/29/b2ecebfc-a80e-45c7-8096-9adfbc2a81dd.JPEG",
                "https://image.heydealer.com/unsafe/1150x0/https://prnd-car-purchase.s3.ap-northeast-2.amazonaws.com/media/cars/carmediafile/2024/11/29/4bbc2294-c14e-45ca-89e2-103d73bd22e7.JPEG",
                "https://image.heydealer.com/unsafe/2250x0/https://prnd-car-purchase.s3.ap-northeast-2.amazonaws.com/media/cars/carmediafile/2024/11/29/fdf82706-8b2e-43fd-82a3-de87638d7500.JPEG",
                "https://image.heydealer.com/unsafe/1150x0/https://prnd-car-purchase.s3.ap-northeast-2.amazonaws.com/media/cars/carmediafile/2024/11/29/b8f30d56-3498-4048-9501-3c5028eefa04.JPEG"
            ]
            return urls.enumerated().map { idx, u in
                VehiclePhotoDTO(id: Int64(vehicleId * 100 + Int64(idx)), photo_url: u, order_index: idx, created_at: now, vehicle_id: vehicleId)
            }
        }
        
        func photos3(for vehicleId: Int64) -> [VehiclePhotoDTO] {
            let urls = [
                "https://image.heydealer.com/unsafe/2250x0/https://prnd-car-purchase.s3.ap-northeast-2.amazonaws.com/media/cars/carmediafile/2025/09/11/09dced50-6f1e-4cee-873a-d6db30268ca1.jpeg",
                "https://image.heydealer.com/unsafe/1150x0/https://prnd-car-purchase.s3.ap-northeast-2.amazonaws.com/media/cars/carmediafile/2025/09/11/b0666165-dfed-4a6a-9838-3e4ca9d29748.jpeg",
                "https://image.heydealer.com/unsafe/1150x0/https://prnd-car-purchase.s3.ap-northeast-2.amazonaws.com/media/cars/carmediafile/2025/09/11/87eef3f0-6afa-403f-81ba-5ed9e057f7b6.jpeg",
                "https://image.heydealer.com/unsafe/2250x0/https://prnd-car-purchase.s3.ap-northeast-2.amazonaws.com/media/cars/carmediafile/2025/09/11/cc942bfd-6820-4056-a5a5-4e2c12fd1f34.jpeg",
                "https://image.heydealer.com/unsafe/1150x0/https://prnd-car-purchase.s3.ap-northeast-2.amazonaws.com/media/cars/carmediafile/2025/09/11/a27aa5ed-1614-4035-ab1c-4325567cc364.jpeg"
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
                title: "Porsche Taycan GTS",
                description: "가성비 전기 SUV",
                manufacturer: "Porsche",
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
                photos: photos1(for: isAuction ? 101 : 1),
                auction: isAuction ? auction(isAuction ? 101 : 1, minutesFromNow: 8, secondsExtra: 5, startOffsetMins: -120, startPrice: 140_000_000) : nil
            ),
            VehicleDTO(
                id: isAuction ? 102 : 2,
                title: "Tesla Cybertruck All-Wheel Drive 파운데이션",
                description: "효율적인 세단",
                manufacturer: "Tesla",
                model: "Cybertruck",
                option_name: "All-Wheel Drive 파운데이션",
                year: 2024,
                mileage: 109,
                fuel_type: "전기",
                transmission: "자동",
                accident_history: nil,
                accident_description: nil,
                vehicle_status: "1인신조",
                engine_cc: nil,
                horsepower: 228,
                color: "화이트",
                additional_info: nil,
                price: 140_000_000,
                is_auction: isAuction,
                auction_id: isAuction ? 12 : nil,
                location_address: "수원",
                favorite_count: 8,
                created_at: now, updated_at: now, seller_id: 5002,
                photos: photos2(for: isAuction ? 102 : 2),
                auction: isAuction ? auction(isAuction ? 102 : 2, minutesFromNow: 25, startOffsetMins: -120, startPrice: 38_000_000) : nil
            ),
            VehicleDTO(
                id: isAuction ? 103 : 3,
                title: "Tesla Model X AWD",
                description: "고급 세단",
                manufacturer: "Tesla",
                model: "Model X",
                option_name: "AWD",
                year: 2020,
                mileage: 54000,
                fuel_type: "전기",
                transmission: "자동",
                accident_history: nil,
                accident_description: nil,
                vehicle_status: "정비이력",
                engine_cc: 3300,
                horsepower: 370,
                color: "블랙",
                additional_info: nil,
                price: 133_000_000,
                is_auction: isAuction,
                auction_id: isAuction ? 13 : nil,
                location_address: "부산",
                favorite_count: 9,
                created_at: now, updated_at: now, seller_id: 5003,
                photos: photos3(for: isAuction ? 103 : 3),
                auction: isAuction ? auction(isAuction ? 103 : 3, minutesFromNow: 180, startOffsetMins: -120, startPrice: 35_000_000) : nil
            )
        ]

        return vehicles
    }
}
