import SwiftUI

struct CarListItemView: View {
    // Model
    let model: CarListItem

    // State
    @State private var isLiked: Bool = false

    // Style
    private let brand = Color.purple400

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                // Vehicle image
                Group {
                    if let name = model.thumbnailName,
                       let url = URL(string: name), url.scheme?.hasPrefix("http") == true {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ZStack { Color.secondary.opacity(0.08); ProgressView() }
                            case .success(let image):
                                image.resizable().scaledToFill()
                            case .failure:
                                Rectangle().fill(Color.secondary.opacity(0.15))
                                    .overlay(Image(systemName: "car.fill").font(.system(size: 40)).foregroundStyle(.secondary))
                            @unknown default:
                                Rectangle().fill(Color.secondary.opacity(0.15))
                            }
                        }
                    } else if let name = model.thumbnailName, UIImage(named: name) != nil {
                        Image(name)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Rectangle()
                            .fill(Color.secondary.opacity(0.15))
                            .overlay(
                                Image(systemName: "car.fill")
                                    .font(.system(size: 40))
                                    .foregroundStyle(.secondary)
                            )
                    }
                }
                .frame(height: 180)
                .clipped()

                // Auction badge
                if model.isAuction {
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

                // Like button
                HStack {
                    Spacer()
                    Button {
                        isLiked.toggle()
                    } label: {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundStyle(isLiked ? Color.likeRed : .secondary)
                            .font(.system(size: 20, weight: .semibold))
                            .padding(8)
                    }
                }
                .buttonStyle(.plain)
                .padding(4)
            }

            // Info area (black bar)
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .center) {
                    // Title
                    Text(model.title)
                        .font(.headline)
                        .foregroundStyle(.black)
                    Spacer()
                    if model.isAuction, let endsAt = model.auctionEndsAt {
                        HStack(spacing: 4) {
                            Image(systemName: "timer")
                            CountdownText(endDate: normalizedAuctionEnd(endsAt))
                        }
                        .foregroundStyle(Color.likeRed)
                        .font(.subheadline)
                    }
                }
                
                Text("\(Formatters.yearText(model.year)) · \(Formatters.mileageText(km: model.mileageKm))")
                    .foregroundStyle(.black.opacity(0.7))
                    .font(.subheadline)

                // Tags
                if !model.tags.isEmpty {
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

                // Price row
                if model.isAuction {
                    HStack {
                        Spacer()
                        Text("최고 입찰가 ")
                            .foregroundStyle(.black)
                            .font(.subheadline)
                        Text(Formatters.priceText(won: model.priceWon))
                            .foregroundStyle(Color.priceGreen)
                            .font(.title2).bold()
                    }
                } else {
                    HStack {
                        Spacer()
                        Text(Formatters.priceText(won: model.priceWon))
                            .foregroundStyle(Color.priceGreen)
                            .font(.title2).bold()
                    }
                }
            }
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

#Preview {
    VStack(spacing: 16) {
        CarListItemView(model: CarRepository.sampleBuyList[0])

        CarListItemView(model: CarRepository.sampleAuctionList[0])
    }
    .padding()
}
