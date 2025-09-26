import Foundation
import FirebaseDatabase

struct AuctionLive: Equatable {
    let id: Int
    let vehicleId: Int?
    let startPrice: Int?
    let currentBidPrice: Int?
    let currentBidUserName: String?
    let startAt: String?
    let endAt: String?
    let status: String?
}

final class FirebaseAuctionService {
    static let shared = FirebaseAuctionService()
    private init() {}

    private let root = Database.database().reference()

    @discardableResult
    func observeAuction(auctionId: Int, onChange: @escaping (AuctionLive?) -> Void) -> UInt {
        let ref = root.child("auctions").child("\(auctionId)")
        return ref.observe(.value) { snap in
            guard let dict = snap.value as? [String: Any] else { onChange(nil); return }
            let live = AuctionLive(
                id: dict["id"] as? Int ?? auctionId,
                vehicleId: dict["vehicleId"] as? Int,
                startPrice: dict["startPrice"] as? Int,
                currentBidPrice: dict["currentBidPrice"] as? Int,
                currentBidUserName: dict["currentBidUserName"] as? String,
                startAt: dict["startAt"] as? String,
                endAt: dict["endAt"] as? String,
                status: dict["status"] as? String
            )
            onChange(live)
        }
    }

    @discardableResult
    func observeAuctionByVehicleIdContinuous(vehicleId: Int, onChange: @escaping (AuctionLive?) -> Void) -> UInt {
        let query = root.child("auctions").queryOrdered(byChild: "vehicleId").queryEqual(toValue: vehicleId)
        return query.observe(.value) { snap in
            guard snap.exists() else { onChange(nil); return }
            var found: AuctionLive?
            for child in snap.children {
                if let c = child as? DataSnapshot, let dict = c.value as? [String: Any] {
                    let live = AuctionLive(
                        id: dict["id"] as? Int ?? Int(c.key) ?? 0,
                        vehicleId: dict["vehicleId"] as? Int,
                        startPrice: dict["startPrice"] as? Int,
                        currentBidPrice: dict["currentBidPrice"] as? Int,
                        currentBidUserName: dict["currentBidUserName"] as? String,
                        startAt: dict["startAt"] as? String,
                        endAt: dict["endAt"] as? String,
                        status: dict["status"] as? String
                    )
                    found = live
                    break
                }
            }
            onChange(found)
        }
    }

    func removeObserver(auctionId: Int, handle: UInt) {
        root.child("auctions").child("\(auctionId)").removeObserver(withHandle: handle)
    }

    // MARK: - Bids (bids/<auctionId>/{autoId: { bidderName, bidPrice, createdAt }})
    @discardableResult
    func observeBids(auctionId: Int, onChange: @escaping ([BidEntry]) -> Void) -> UInt {
        let ref = root.child("bids").child("\(auctionId)")
        return ref.observe(.value) { snap in
            var entries: [BidEntry] = []
            for child in snap.children {
                guard let c = child as? DataSnapshot, let dict = c.value as? [String: Any] else { continue }
                let name = dict["bidderName"] as? String ?? "-"
                let price = dict["bidPrice"] as? Int ?? 0
                let createdAt = (dict["createdAt"] as? String).flatMap(Self.parseISO8601) ?? Date()
                entries.append(BidEntry(bidderName: name, priceWon: price, placedAt: createdAt))
            }
            // 최신순 정렬 (createdAt 내림차순)
            entries.sort { $0.placedAt > $1.placedAt }
            onChange(entries)
        }
    }

    func removeBidsObserver(auctionId: Int, handle: UInt) {
        root.child("bids").child("\(auctionId)").removeObserver(withHandle: handle)
    }

    private static func parseISO8601(_ s: String) -> Date? {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = iso.date(from: s) { return d }
        iso.formatOptions = [.withInternetDateTime]
        if let d2 = iso.date(from: s) { return d2 }
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .iso8601)
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return df.date(from: s)
    }
}


