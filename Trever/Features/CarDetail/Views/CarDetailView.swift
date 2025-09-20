import SwiftUI

struct CarDetailView: View {
    var detail: CarDetail
    @EnvironmentObject private var vm: CarDetailViewModel

    private let brand = Color.purple400
    @State private var showImageViewer = false
    @State private var viewerIndex = 0
    @State private var fullscreenSources: [String] = []
    @State private var showBidSheet: Bool = false
    @State private var showMarkSoldSheet: Bool = false
//    @State private var soldCompleted: Bool = false

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
                if detail.isAuction == "Y" { bidHistorySection }

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
        .sheet(isPresented: $showMarkSoldSheet) {
//            MarkSoldSheet(buyers: detail.potentialBuyers ?? []) { buyerId in
//                // TODO: API call with buyerId
////                soldCompleted = true
//                showMarkSoldSheet = false
//            }
//            .presentationDetents([.medium, .large])
//            .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $showBidSheet) {
//            AuctionBidSheet(
//                currentPriceWon: detail.priceWon,
//                startPriceWon: detail.startPrice,
//                onConfirm: { _, _ in
//                    showBidSheet = false
//                }
//            )
//            .presentationDetents([.fraction(0.3)])
//            .presentationDragIndicator(.hidden)
        }
    }

    // MARK: - 이미지 페이저
    private var imagePager: some View {
        TabView(selection: $viewerIndex) {
            let imageUrls = detail.photos?.sorted { $0.orderIndex < $1.orderIndex }.map { $0.photoUrl } ?? []
            if imageUrls.isEmpty {
                // 이미지가 없는 경우
                Rectangle()
                    .fill(Color.grey100)
                    .overlay(
                        VStack(spacing: 12) {
                            Image(systemName: "car.fill")
                                .font(.system(size: 48))
                                .foregroundStyle(.secondary)
                            Text("이미지가 없습니다")
                                .foregroundStyle(.secondary)
                                .font(.subheadline)
                        }
                    )
                    .frame(height: 400)
                    .tag(0)
            } else {
                ForEach(Array(imageUrls.enumerated()), id: \.offset) { idx, name in
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
                                            fullscreenSources = imageUrls
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
                                    fullscreenSources = imageUrls
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
                        // 메인 차량명: (제조사 + 모델) 없으면 기존 title
                        Text(mainVehicleName)
                            .font(.title3)
                            .bold()
                        // 차량 세부 옵션 명: optionName(=title) or subTitle
                        if let opt = optionDisplayName {
                            Text(opt).font(.title3).bold()
                        }
                    }
                    Spacer()
                    // 찜 하기
                    HStack(spacing: 8) {
//                        Text("\(detail.likes)")
//                            .foregroundStyle(.secondary)
//                            .font(.subheadline)
                        Image(systemName: "heart")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // 차량 연식 / 주행 거리
                Text("\(Formatters.yearText(detail.yearValue ?? 0)) · \(Formatters.mileageText(km: detail.mileage ?? 0))")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)

                // 차량 가격 및 경매 뱃지
                HStack(alignment: .center, spacing: 8) {
                    let livePrice = vm.liveAuction?.currentBidPrice ?? vm.liveAuction?.startPrice
                    let priceToShow = livePrice ?? detail.price
                    if let price = priceToShow, price > 0 {
                        Text(Formatters.priceText(won: price))
                            .font(.title2).bold()
                            .foregroundStyle(Color.priceGreen)
                    } else {
                        Text("가격 문의")
                            .font(.title2).bold()
                            .foregroundStyle(Color.priceGreen)
                    }
                    Spacer()
                    if detail.isAuction == "Y" {
                        Badge(text: "경매", color: Color.likeRed)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 24)
    }

    private var mainVehicleName: String {
        let parts = [detail.manufacturer, detail.model].compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        if parts.isEmpty { return "차량" }
        return parts.joined(separator: " ")
    }

    private var optionDisplayName: String? {
        if let opt = detail.carName, !opt.isEmpty { return opt }
        return detail.description
    }

    // MARK: - 차량 스펙 옵션 섹션
    private var specSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            let specs = buildSpecs()
            if !specs.isEmpty {
                ForEach(specs.sorted(by: { $0.key < $1.key }), id: \.key) { kv in
                    HStack(alignment: .top) {
                        Text(kv.key)
                            .frame(width: 120, alignment: .leading)
                            .foregroundStyle(.secondary)
                        Text(kv.value)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .font(.subheadline)
                }
            } else {
                Text("차량 스펙 정보가 없습니다.")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            }
        }
        .padding(.horizontal, 16)
    }
    
    private func buildSpecs() -> [String: String] {
        var specs: [String: String] = [:]
        if let fuelType = detail.fuelType, !fuelType.isEmpty { specs["연료"] = fuelType }
        if let transmission = detail.transmission, !transmission.isEmpty { specs["변속기"] = transmission }
        if let color = detail.color, !color.isEmpty { specs["색상"] = color }
        if let horsepower = detail.horsepower { specs["마력"] = "\(horsepower)hp" }
        if let engineCc = detail.engineCc { specs["배기량"] = "\(engineCc)cc" }
        if let accidentHistory = detail.accidentHistory { specs["사고이력"] = accidentHistory == "Y" ? "있음" : "없음" }
        return specs
    }

    // MARK: - 차량 상세 설명 섹션
    private var descriptionSection: some View {
        VStack(alignment: .center) {
            Text(detail.description ?? "차량 설명이 없습니다.")
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
                    AuctionBidHistoryView(vehicleId: Int64(detail.id ?? 0))
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
//            ForEach(detail.bids.prefix(5)) { bid in
//                BidListItem(bid: bid)
//            }
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
                    row(label: "판매자", value: detail.sellerName ?? "정보 없음")
                    row(label: "차량 상태", value: detail.vehicleStatus ?? "정보 없음")
//                    if let createdAt = detail.createdAt {
//                        let dateFormatter = ISO8601DateFormatter()
//                        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
//                        if let date = dateFormatter.date(from: createdAt) {
//                            row(label: "등록일", value: Formatters.dateText(date))
//                        }
//                    }
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
            if detail.isAuction == "Y" {   // 경매 매물인 경우
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
                            if let end = resolvedEndDate() {
                                CountdownText(endDate: normalizedAuctionEnd(end))
                                    .font(.title2)
                            } else {
                                Text("-").font(.title2)
                            }
                        }
                        .foregroundStyle(Color.likeRed)
                        .font(.subheadline)
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 12)
                    .background(Capsule().fill(Color.likeRed).opacity(0.07))
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            let livePrice = vm.liveAuction?.currentBidPrice ?? vm.liveAuction?.startPrice
                            let priceToShow = livePrice ?? detail.price
                            if let price = priceToShow, price > 0 {
                                Text(Formatters.priceText(won: price))
                                    .foregroundStyle(Color.priceGreen)
                                    .font(.title2).bold()
                                if let sp = vm.liveAuction?.startPrice ?? detail.price, sp > 0 {
                                    Text("시작가 \(Formatters.priceText(won: sp))")
                                        .foregroundStyle(Color.grey300)
                                        .font(.subheadline).bold()
                                }
                            } else {
                                Text("가격 문의")
                                    .foregroundStyle(Color.priceGreen)
                                    .font(.title2).bold()
                                Text("문의 후 협의")
                                    .foregroundStyle(Color.grey300)
                                    .font(.subheadline).bold()
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        CustomButton(
                            title: "상위 입찰",
                            action: { showBidSheet = true },
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
                // 일반 매물의 경우 간단한 버튼들만 표시
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

    private func resolvedEndDate() -> Date? {
        if let s = vm.liveAuction?.endAt, let d = parseISO8601(s) { return d }
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

#Preview {
    NavigationStack { CarDetailScreen(vehicleId: 1) }
}
