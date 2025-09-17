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
                // 이미지 페이저
                imagePager

                // 경매 매물 기본 정보 섹션
                headerSection

                // 차량 스펙 옵션 섹션
                specSection

                // 차량 상세 설명 섹션
                descriptionSection

                // 차량 입찰 내역 섹션
                if detail.isAuction { bidHistorySection }

                // 판매자 정보 섹션
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

    // MARK: - 이미지 페이저
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

    // MARK: - 경매 매물 기본 정보 섹션
    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    VStack(alignment: .leading) {
                        // 차량 이름
                        Text(detail.title)
                            .font(.title3)
                            .bold()
                        
                        // 차량 세부 옵션 명
                        if let sub = detail.subTitle {
                            Text(sub).font(.title3).bold()
                        }
                    }
                    Spacer()
                    // 찜 하기
                    HStack(spacing: 8) {
                        Text("\(detail.likes)")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                        Image(systemName: "heart")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // 차량 연식 / 주행 거리
                Text("\(Formatters.yearText(detail.year)) · \(Formatters.mileageText(km: detail.mileageKm))")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)

                // 차량 가격 및 경매 뱃지
                HStack(alignment: .center, spacing: 8) {
                    Text(Formatters.priceText(won: detail.priceWon))
                        .font(.title2).bold()
                        .foregroundStyle(Color.priceGreen)
                    Spacer()
                    if detail.isAuction {
                        Badge(text: "경매", color: Color.likeRed)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 24)
    }

    // MARK: - 차량 스펙 옵션 섹션
    private var specSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(detail.specs.sorted(by: { $0.key < $1.key }), id: \.key) { kv in
                HStack(alignment: .top) {
                    Text(kv.key)
                        .frame(width: 120, alignment: .leading)
                        .foregroundStyle(.secondary)
                    Text(kv.value)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .font(.subheadline)
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - 차량 상세 설명 섹션
    private var descriptionSection: some View {
        VStack(alignment: .center) {
            Text(detail.description)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.purple50))

        }
        .padding(.horizontal, 16)
    }

    // MARK: - 차량 입찰 내역 섹션
    private var bidHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("입찰 내역")
                    .font(.title3)
                    .bold()
                Spacer()
                NavigationLink {
                    AuctionBidHistoryView(carId: detail.id)
                } label: {
                    Text("더보기")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Image("arrow_right")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.bottom, 8)
            // 상위 5개 입찰 내역만 노출
            ForEach(detail.bids.prefix(5)) { bid in
                BidListItem(bid: bid)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - 판매자 정보 섹션
    private var sellerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Text("판매자 정보")
                    .font(.title3)
                    .bold()
                Spacer()
                Circle().fill(Color.grey100).frame(width: 48, height: 48)
                    .overlay(Image(systemName: "person").foregroundStyle(.secondary))

            }
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    row(label: "판매자 ID", value: detail.seller.name)
                    row(label: "주소", value: detail.seller.address)
                    row(label: "등록일", value: Formatters.dateText(detail.seller.createdAt))
                    row(label: "수정일", value: Formatters.dateText(detail.seller.updatedAt))
                }
                
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 24)
    }

    private func row(label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(label).foregroundStyle(.secondary).frame(width: 120, alignment: .leading)
            Text(value)
        }
        .font(.subheadline)
    }

    // MARK: - 하단 액션 바 섹션
    private var bottomActionBar: some View {
        HStack(spacing: 12) {
            if detail.isAuction {   // 경매 매물인 경우
                VStack(alignment: .center, spacing: 12) {
                    HStack(spacing: 8) {
                        VStack(spacing: 0) {
                            Text("상위 입찰자")
                                .font(.caption2)
                                .foregroundStyle(Color.grey300)
                            HStack {
                                Circle().fill(Color.grey100).frame(width: 25, height: 25)
                                    .overlay(Image(systemName: "person").foregroundStyle(.secondary))
                                Text("홍길동")
                                    .font(.subheadline)
                            }
                        }
                        Spacer()
                        HStack(spacing: 4) {
                            Image("gavel")
                            Text(detail.auctionEndsAt.map { Formatters.timerText(until: $0) } ?? "-")
                                .font(.title2)
                        }
                        .foregroundStyle(Color.likeRed)
                        .font(.subheadline)
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 12)
                    .background(Capsule().fill(Color.likeRed).opacity(0.07))
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(Formatters.priceText(won: detail.priceWon))
                                .foregroundStyle(Color.priceGreen)
                                .font(.title2).bold()
                            Text("시작가 \(Formatters.priceText(won: detail.startPrice))")
                                .foregroundStyle(Color.grey300)
                                .font(.subheadline).bold()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        CustomButton(
                            title: "상위 입찰",
                            action: {},
                            fontSize: 16,
                            fontWeight: .semibold,
                            cornerRadius: 12,
                            horizontalPadding: 0,
                            foregroundColor: .white,
                            backgroundColor: brand,
                            pressedBackgroundColor: brand.opacity(0.85),
                            shadowColor: Color.black.opacity(0.1)
                        )
                        .frame(maxWidth: .infinity)
                    }
                }
            } else {    // 일반 매물인 경우
                CustomButton(
                    title: "문의하기",
                    action: {},
                    fontSize: 16,
                    fontWeight: .semibold,
                    cornerRadius: 12,
                    horizontalPadding: 0,
                    foregroundColor: brand,
                    backgroundColor: Color(.systemBackground),
                    pressedBackgroundColor: Color.purple50.opacity(0.5),
                    borderColor: brand,
                    shadowColor: nil
                )
                CustomButton(
                    title: "구매하기",
                    action: {},
                    fontSize: 16,
                    fontWeight: .semibold,
                    cornerRadius: 12,
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
        .background(Color.white)
        .background(
            Color.white
                .shadow(
                    color: Color.black.opacity(0.1),
                    radius: 8,
                    x: 0,
                    y: -2
                )
        )
    }
}

#Preview {
    NavigationStack {
        let item = CarRepository.sampleAuctionList[0]
        CarDetailView(detail: CarRepository.mockDetail(from: item))
    }
}
