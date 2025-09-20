import SwiftUI

struct AuctionCarListItemView: View {
    let vehicle: VehicleAPIItem
    let live: AuctionLive?
    
    // State
    @State private var isLiked = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                thumbnail
                    .frame(height: 180)
                    .clipped()

                auctionBadge

                HStack { Spacer(); likeButton }
                    .buttonStyle(.plain)
                    .padding(4)
            }

            infoSection
                .padding(12)
                .background(Color.white)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 0.5)
        )
    }
}

// MARK: - Subviews
private extension AuctionCarListItemView {
    @ViewBuilder
    var thumbnail: some View {
        if let urlString = vehicle.representativePhotoUrl,
           let url = URL(string: urlString),
           url.scheme?.hasPrefix("http") == true {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ZStack { Color.secondary.opacity(0.08); ProgressView() }
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure:
                    placeholder
                @unknown default:
                    placeholder
                }
            }
        } else {
            placeholder
        }
    }

    var placeholder: some View {
        Rectangle()
            .fill(Color.secondary.opacity(0.15))
            .overlay(
                Image(systemName: "car.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.secondary)
            )
    }

    var auctionBadge: some View {
        Text("경매")
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.white)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(
                Capsule().fill(Color(red: 1.0, green: 0.54, blue: 0.54))
            )
            .padding(8)
    }

    var likeButton: some View {
        Button {
            isLiked.toggle()
        } label: {
            Image(systemName: isLiked ? "heart.fill" : "heart")
                .foregroundStyle(isLiked ? Color.likeRed : .secondary)
                .font(.system(size: 20, weight: .semibold))
                .padding(8)
        }
    }

    var infoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center) {
                Text(vehicle.carName ?? "차량")
                    .font(.headline)
                    .foregroundStyle(.black)
                Spacer()
                // 경매 종료까지 남은 시간
                if let end = resolvedEndDate() {
                    HStack(spacing: 4) {
                        Image(systemName: "timer")
                        CountdownText(endDate: normalizedAuctionEnd(end))
                            .font(.subheadline)
                    }
                    .foregroundStyle(Color.likeRed)
                    .font(.subheadline)
                }
            }

            Text("\(Formatters.yearText(vehicle.year_value ?? 0)) · \(Formatters.mileageText(km: vehicle.mileage ?? 0))")
                .foregroundStyle(.black.opacity(0.7))
                .font(.subheadline)

            if let options = vehicle.mainOptions, !options.isEmpty { 
                tagsView(options: options) 
            }

            priceRow
        }
    }

    func tagsView(options: [String]) -> some View {
        HStack(spacing: 5) {
            ForEach(Array(options.prefix(3)), id: \.self) { option in
                Text(option)
                    .font(.caption2)
                    .foregroundStyle(.black.opacity(0.7))
                    .padding(.vertical, 4)
                    .padding(.horizontal, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(Color.gray.opacity(0.2))
                    )
            }
        }
    }

    @ViewBuilder
    var priceRow: some View {
        HStack {
            Spacer()
            let priceToShow = live?.currentBidPrice ?? live?.startPrice ?? vehicle.currentPrice ?? vehicle.startPrice ?? vehicle.price
            if let price = priceToShow, price > 0 {
                if live?.currentBidPrice != nil {
                    Text("현재 입찰가 ")
                        .foregroundStyle(.black)
                        .font(.subheadline)
                } else {
                    Text("시작가 ")
                        .foregroundStyle(.black)
                        .font(.subheadline)
                }
                Text(Formatters.priceText(won: price))
                    .foregroundStyle(Color.priceGreen)
                    .font(.title2).bold()
            } else {
                Text("가격 문의")
                    .foregroundStyle(Color.priceGreen)
                    .font(.title2).bold()
            }
        }
    }

    private func resolvedEndDate() -> Date? {
        // Priority: live.endAt -> vehicle.endAt
        if let s = live?.endAt, let d = parseISO8601(s) { return d }
        if let s = vehicle.endAt, let d = parseISO8601(s) { return d }
        return nil
    }

    private func parseISO8601(_ s: String) -> Date? {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = iso.date(from: s) { return d }
        iso.formatOptions = [.withInternetDateTime]
        if let d2 = iso.date(from: s) { return d2 }
        // Fallback: no timezone provided, treat as local time
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .iso8601)
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return df.date(from: s)
    }
}

//#Preview {
//    let preview = VehicleAPIItem(
//        id: 115,
//        carName: "BMW 520d",
//        carNumber: "34나 5678",
//        manufacturer: "BMW",
//        model: "520d",
//        year_value: 2020,
//        mileage: 28500,
//        transmission: "자동",
//        vehicleStatus: "판매중",
//        fuelType: "가솔린",
//        price: nil,
//        isAuction: "Y",
//        representativePhotoUrl: "",
//        locationAddress: "https://storage.googleapis.com/trever-ec541.firebasestorage.app/vehicles/1638692d-4ce6-4ad6-af58-c7cb15cfe429.jpg",
//        favoriteCount: 0,
//        createdAt: "2025-09-19T01:14:15.565347",
//        vehicleTypeName: "중형",
//        mainOptions: ["내비게이션", "썬루프", "어라운드뷰"],
//        totalOptionsCount: 8,
//        auctionId: 25000000,
//        startPrice: 28000000,
//        currentPrice: 10000000,
//        startAt: "2025-09-25T23:59:59",
//        endAt: "진행중",
//        auctionStatus: "ACTIVE",
//        bidCount: 4
//    )
//    AuctionCarListItemView(vehicle: preview, live: AuctionLive?).padding()
//}
