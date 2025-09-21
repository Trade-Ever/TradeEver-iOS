import SwiftUI

struct CarListItemView: View {
    // ViewModel representing a car to display
    private struct ViewModel {
        let title: String
        let year: Int
        let mileageKilometers: Int
        let thumbnailURLString: String?
        let tags: [String]
        let priceWon: Int
        let isAuction: Bool
        let auctionEndsAt: Date?
    }

    private let model: ViewModel

    // State
    @State private var isLiked = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                thumbnail
                    .frame(height: 180)
                    .clipped()

                if model.isAuction { auctionBadge }

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
private extension CarListItemView {
    @ViewBuilder
    var thumbnail: some View {
        if let urlString = model.thumbnailURLString,
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
        } else if let name = model.thumbnailURLString, UIImage(named: name) != nil {
            Image(name)
                .resizable()
                .scaledToFill()
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
                Text(model.title)
                    .font(.headline)
                    .foregroundStyle(.black)
                Spacer()
                if model.isAuction, let endDate = model.auctionEndsAt {
                    HStack(spacing: 4) {
                        Image(systemName: "timer")
                        CountdownText(endDate: normalizedAuctionEnd(endDate))
                    }
                    .foregroundStyle(Color.likeRed)
                    .font(.subheadline)
                }
            }

            Text("\(Formatters.yearText(model.year)) · \(Formatters.mileageText(km: model.mileageKilometers))")
                .foregroundStyle(.black.opacity(0.7))
                .font(.subheadline)

            HStack {
                if !model.tags.isEmpty { tagsView }
                Spacer()
                priceRow
            }
        }
    }

    var tagsView: some View {
        HStack(spacing: 5) {
            ForEach(model.tags, id: \.self) { tag in
                Text(tag)
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
            if model.isAuction {
                Text("최고 입찰가 ")
                    .foregroundStyle(.black)
                    .font(.subheadline)
            }
            Text(Formatters.priceText(won: model.priceWon))
                .foregroundStyle(Color.priceGreen)
                .font(.title2).bold()
        }
    }
}

// MARK: - Initializers
extension CarListItemView {
    init(model: CarListItem) {
        let vm = ViewModel(
            title: model.title,
            year: model.year,
            mileageKilometers: model.mileageKm,
            thumbnailURLString: model.thumbnailName,
            tags: model.tags,
            priceWon: model.priceWon,
            isAuction: model.isAuction,
            auctionEndsAt: model.auctionEndsAt
        )
        self.init(model: vm)
    }

    init(apiModel v: VehicleAPIItem) {
        let tags = Array((v.mainOptions ?? []).prefix(3))
        let isAuction = v.isAuction.uppercased() == "Y"
        let startPrice = v.startPrice ?? v.price ?? 0
        let price = v.currentPrice ?? v.price ?? startPrice
        let vm = ViewModel(
            title: (v.manufacturer != nil && v.model != nil ? "\(v.manufacturer!) \(v.model!)" : (v.carName ?? v.model ?? "차량")),
            year: v.year_value ?? 0,
            mileageKilometers: v.mileage ?? 0,
            thumbnailURLString: v.representativePhotoUrl,
            tags: tags,
            priceWon: price,
            isAuction: isAuction,
            auctionEndsAt: nil
        )
        self.init(model: vm)
    }
}

#Preview {
    let preview = VehicleAPIItem(
        id: 34,
        carName: "현대 아반떼 CN7",
        carNumber: nil,
        manufacturer: "현대",
        model: "아반떼 CN7",
        year_value: 2021,
        mileage: 35000,
        transmission: "자동",
        vehicleStatus: "판매중",
        fuelType: "경유",
        price: 18_500_000,
        isAuction: "N",
        representativePhotoUrl: nil,
        locationAddress: nil,
        favoriteCount: 0,
        createdAt: nil,
        vehicleTypeName: "준중형",
        mainOptions: ["내비게이션"],
        totalOptionsCount: 4,
        auctionId: nil,
        startPrice: nil,
        currentPrice: nil,
        startAt: nil,
        endAt: nil,
        auctionStatus: nil,
        bidCount: nil
    )
    return CarListItemView(apiModel: preview).padding()
}
