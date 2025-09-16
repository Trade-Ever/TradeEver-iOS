import SwiftUI

struct CarDetailView: View {
    var detail: CarDetail

    private let brand = Color.purple400
    @State private var showImageViewer = false
    @State private var viewerIndex = 0
    @State private var fullscreenSources: [String] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                imagePager

                headerSection

                Divider().padding(.horizontal, 16)

                specSection

                descriptionSection

                if detail.isAuction { bidHistorySection }

                sellerSection
                Spacer(minLength: 40)
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) { bottomActionBar }
        .background(Color(.systemBackground))
        .tabBarHidden(true)
    }

    private var imagePager: some View {
        TabView(selection: $viewerIndex) {
            ForEach(Array(detail.imageNames.enumerated()), id: \.offset) { idx, name in
                Group {
                    if let url = URL(string: name), url.scheme?.hasPrefix("http") == true {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ZStack { Color.grey100; ProgressView() }
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: UIScreen.main.bounds.width, height: 400)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        fullscreenSources = detail.imageNames
                                        viewerIndex = idx
                                        showImageViewer = true
                                    }
                            case .failure:
                                Rectangle().fill(Color.grey100)
                                    .overlay(Image(systemName: "car.fill").font(.system(size: 48)).foregroundStyle(.secondary))
                            @unknown default:
                                Rectangle().fill(Color.grey100)
                            }
                        }
                    } else if UIImage(named: name) != nil {
                        Image(name)
                            .resizable()
                            .scaledToFill()
                            .contentShape(Rectangle())
                            .onTapGesture {
                                fullscreenSources = detail.imageNames
                                viewerIndex = idx
                                showImageViewer = true
                            }
                    } else {
                        Rectangle()
                            .fill(Color.grey100)
                            .overlay(Image(systemName: "car.fill").font(.system(size: 48)).foregroundStyle(.secondary))
                    }
                }
                .frame(height: 400)
                .clipped()
                .tag(idx)
            }
        }
        .tabViewStyle(.page)
        .frame(height: 400)
        .ignoresSafeArea(edges: .top)
        .fullScreenCover(isPresented: $showImageViewer) {
            FullscreenPhotoViewer(isPresented: $showImageViewer, currentIndex: $viewerIndex, sources: $fullscreenSources)
        }
    }

    // Local viewer removed; remote-only flow
    // No need for URL helper when binding a String for ImageViewerRemote

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text(detail.title)
                    .font(.title3).bold()
                if let sub = detail.subTitle {
                    Text(sub).font(.title3).bold()
                }
                Text("\(Formatters.yearText(detail.year)) · \(Formatters.mileageText(km: detail.mileageKm))")
                    .foregroundStyle(.secondary)

                // Price and status badge
                HStack(alignment: .center, spacing: 8) {
                    Text(Formatters.priceText(won: detail.priceWon))
                        .font(.title3).bold()
                        .foregroundStyle(Color.priceGreen)
                    if detail.isAuction {
                        badge(text: "경매", color: Color.likeRed)
                    } else {
                        badge(text: "예약 중", color: brand)
                    }
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Text("\(detail.likes)")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                    Image(systemName: "heart")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private var specSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(detail.specs.sorted(by: { $0.key < $1.key }), id: \.key) { kv in
                HStack(alignment: .top) {
                    Text(kv.key).frame(width: 80, alignment: .leading)
                        .foregroundStyle(.secondary)
                    Text(kv.value).frame(maxWidth: .infinity, alignment: .leading)
                }
                .font(.subheadline)
            }
        }
        .padding(.horizontal, 16)
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.purple50.opacity(0.5))
                .overlay(
                    VStack(alignment: .leading, spacing: 8) {
                        Text(detail.description)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                            .padding(16)
                    }
                )
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 16)
    }

    private var bidHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("입찰 내역").font(.headline)
                Spacer()
                NavigationLink {
                    AuctionBidHistoryView(carId: detail.id)
                } label: {
                    Text("더보기")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            ForEach(detail.bids) { bid in
                bidRow(name: bid.bidderName, price: Formatters.priceText(won: bid.priceWon))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.grey50)
    }

    private func bidRow(name: String, price: String) -> some View {
        HStack {
            Circle().fill(Color.grey100).frame(width: 32, height: 32)
                .overlay(Image(systemName: "person").foregroundStyle(.secondary))
            Text(name)
            Spacer()
            Text(price).bold().foregroundStyle(Color.priceGreen)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)).shadow(color: .black.opacity(0.04), radius: 4, y: 2))
    }

    private var sellerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("판매자 정보").font(.headline)
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    row(label: "판매자 ID", value: detail.seller.name)
                    row(label: "주소", value: detail.seller.address)
                    row(label: "등록일", value: Formatters.dateText(detail.seller.createdAt))
                    row(label: "수정일", value: Formatters.dateText(detail.seller.updatedAt))
                }
                Spacer()
                Circle().fill(Color.grey100).frame(width: 48, height: 48)
                    .overlay(Image(systemName: "person").foregroundStyle(.secondary))
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 80)
    }

    private func row(label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(label).foregroundStyle(.secondary).frame(width: 80, alignment: .leading)
            Text(value)
        }
        .font(.subheadline)
    }

    private func badge(text: String, color: Color) -> some View {
        Text(text)
            .font(.caption)
            .foregroundStyle(.white)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(Capsule().fill(color))
    }

    private var bottomActionBar: some View {
        HStack(spacing: 12) {
            if detail.isAuction {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        badge(text: "상위 입찰자", color: Color.purple100)
                        HStack(spacing: 4) {
                            Image(systemName: "timer")
                            Text(detail.auctionEndsAt.map { Formatters.timerText(until: $0) } ?? "-")
                        }
                        .foregroundStyle(Color.likeRed)
                        .font(.subheadline)
                    }
                    Text(Formatters.priceText(won: detail.priceWon))
                        .foregroundStyle(Color.priceGreen)
                        .font(.title3).bold()
                }
                Spacer()
                CustomButton(
                    title: "상위 입찰",
                    action: {},
                    fontSize: 16,
                    fontWeight: .semibold,
                    cornerRadius: 12,
                    height: 48,
                    horizontalPadding: 0,
                    maxWidth: 140,
                    foregroundColor: .white,
                    backgroundColor: brand,
                    pressedBackgroundColor: brand.opacity(0.85),
                    shadowColor: Color.black.opacity(0.1)
                )
            } else {
                CustomButton(
                    title: "문자 문의",
                    action: {},
                    fontSize: 16,
                    fontWeight: .semibold,
                    cornerRadius: 12,
                    height: 48,
                    horizontalPadding: 0,
                    foregroundColor: brand,
                    backgroundColor: Color(.systemBackground),
                    pressedBackgroundColor: Color.purple50.opacity(0.5),
                    borderColor: brand,
                    shadowColor: nil
                )
                CustomButton(
                    title: "전화 문의",
                    action: {},
                    fontSize: 16,
                    fontWeight: .semibold,
                    cornerRadius: 12,
                    height: 48,
                    horizontalPadding: 0,
                    foregroundColor: .white,
                    backgroundColor: brand,
                    pressedBackgroundColor: brand.opacity(0.85),
                    shadowColor: Color.black.opacity(0.1)
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }
}

#Preview {
    NavigationStack {
        let item = CarRepository.sampleAuctionList[0]
        CarDetailView(detail: CarRepository.mockDetail(from: item))
    }
}
