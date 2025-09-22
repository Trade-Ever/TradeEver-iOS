import SwiftUI
import Foundation

struct CarDetailView: View {
    var detail: CarDetail
    @EnvironmentObject private var vm: CarDetailViewModel

    private let brand = Color.purple400
    @State private var showImageViewer = false
    @State private var viewerIndex = 0
    @State private var fullscreenSources: [String] = []
    @State private var showBidSheet: Bool = false
    @State private var showMarkSoldSheet: Bool = false
    @StateObject private var favoriteManager = FavoriteManager.shared
    @State private var isTogglingFavorite = false
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
        .onAppear {
            // 전역 상태에 초기 값 설정 (아직 설정되지 않은 경우에만)
            if favoriteManager.favoriteStates[detail.id] == nil {
                favoriteManager.setFavoriteState(vehicleId: detail.id, isFavorite: detail.favorite ?? false)
            }
            // 찜하기 카운트도 설정
            if let favoriteCount = detail.favoriteCount {
                favoriteManager.setFavoriteCount(vehicleId: detail.id, count: favoriteCount)
            }
        }
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
            let currentPrice = vm.liveAuction?.currentBidPrice ?? vm.liveAuction?.startPrice ?? detail.price ?? 0
            let startPrice = vm.liveAuction?.startPrice ?? detail.price ?? 0
            
            AuctionBidSheet(
                currentPriceWon: currentPrice,
                startPriceWon: startPrice,
                onConfirm: { incrementMan, newPriceWon in
                    Task {
                        await submitBid(bidPrice: newPriceWon)
                    }
                    showBidSheet = false
                }
            )
            .presentationDetents([.fraction(0.3)])
            .presentationDragIndicator(.hidden)
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
                        if let favoriteCount = favoriteManager.favoriteCount(vehicleId: detail.id) {
                            Text("\(favoriteCount)")
                                .foregroundStyle(.secondary)
                                .font(.subheadline)
                        }
                        Button {
                            toggleFavorite()
                        } label: {
                            if isTogglingFavorite {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .foregroundStyle(.secondary)
                            } else {
                                let isFavorite = favoriteManager.isFavorite(vehicleId: detail.id)
                                Image(systemName: isFavorite ? "heart.fill" : "heart")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(isFavorite ? Color.likeRed : .secondary)
                            }
                        }
                        .disabled(isTogglingFavorite)
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
                ForEach(specs, id: \.0) { key, value in
                    HStack(alignment: .top) {
                        Text(key)
                            .frame(width: 120, alignment: .leading)
                            .foregroundStyle(.secondary)
                        Text(value)
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
    
    private func buildSpecs() -> [(String, String)] {
        var specs: [(String, String)] = []

        // 기본 정보
        if let carNumber = detail.carNumber, !carNumber.isEmpty { specs.append(("차량번호", carNumber)) }
//        if let carName = detail.carName, !carName.isEmpty { specs.append(("차명", carName)) }
//        if let manufacturer = detail.manufacturer, !manufacturer.isEmpty { specs.append(("제조사", manufacturer)) }
//        if let model = detail.model, !model.isEmpty { specs.append(("모델", model)) }
//
//        // 연식 / 주행거리
//        if let year = detail.yearValue { specs.append(("연식", Formatters.yearText(year))) }
//        if let mileage = detail.mileage { specs.append(("주행거리", Formatters.mileageText(km: mileage))) }

        // 파워트레인/제원
        if let fuelType = detail.fuelType, !fuelType.isEmpty { specs.append(("연료", fuelType)) }
        if let transmission = detail.transmission, !transmission.isEmpty { specs.append(("변속기", transmission)) }
        if let engineCc = detail.engineCc { specs.append(("배기량", "\(engineCc)cc")) }
        if let horsepower = detail.horsepower { specs.append(("마력", "\(horsepower)hp")) }

        // 외관/차종
        if let color = detail.color, !color.isEmpty { specs.append(("색상", color)) }
        if let vehicleType = detail.vehicleTypeName, !vehicleType.isEmpty { specs.append(("차종", vehicleType)) }

        // 사고 이력 및 설명
        if let accidentHistory = detail.accidentHistory {
            let hasAccident = (accidentHistory == "Y")
            specs.append(("사고이력", hasAccident ? "있음" : "없음"))
            if hasAccident, let accDesc = detail.accidentDescription, !accDesc.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                specs.append(("사고설명", accDesc))
            }
        }

        // 설명(상세 설명)
        if let desc = detail.description, !desc.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            specs.append(("설명", desc))
        }

        // 옵션 목록 (샘플 payload의 `options` 또는 기존 필드 대체)
        if let options = detail.options, !options.isEmpty {
            specs.append(("옵션", options.joined(separator: ", ")))
        }

        return specs
    }

    // MARK: - 차량 상세 설명 섹션
    private var descriptionSection: some View {
        VStack(alignment: .center) {
            Text(detail.description ?? "차량 설명이 없습니다.")
                .font(.subheadline)
                .foregroundStyle(.primary)
                .padding(16)
                .frame(maxWidth: .infinity)
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
                    AuctionBidHistoryView(vehicleId: Int64(detail.id), auctionId: detail.auctionId)
                        .environmentObject(vm)
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
            // 상위 3개 입찰 내역 (실시간)
            if vm.topBids.isEmpty {
                Text("입찰 내역이 없습니다.")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ForEach(vm.topBids) { bid in
                    BidListItem(bid: bid)
                }
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
                
                // 판매자 프로필 이미지
                if let profileImageUrl = detail.sellerProfileImageUrl, !profileImageUrl.isEmpty {
                    AsyncImage(url: URL(string: profileImageUrl)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Circle()
                            .fill(Color.grey100)
                            .overlay(Image(systemName: "person").foregroundStyle(.secondary))
                    }
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.grey100)
                        .frame(width: 48, height: 48)
                        .overlay(Image(systemName: "person").foregroundStyle(.secondary))
                }
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
                                Text(vm.liveAuction?.currentBidUserName ?? "입찰자 없음")
                                    .font(.subheadline)
                            }
                        }
                        Spacer()
                        HStack(spacing: 4) {
                            Image("gavel")
                            if let status = vm.liveAuction?.status {
                                switch status {
                                case "UPCOMING":
                                    // 시작 대기: 시작 시간까지 카운트다운
                                    if let start = resolvedStartDate() {
//                                        print("UPCOMING - 시작 시간 파싱 성공: \(start)")
                                        HStack(spacing: 4) {
                                            Text("경매 시작까지")
                                                .font(.subheadline)
                                                .foregroundStyle(Color.blue.opacity(0.8))
                                            CountdownText(endDate: start)
                                                .font(.title2)
                                        }
                                    } else {
//                                        print("UPCOMING - 시작 시간 파싱 실패")
                                        Text("시작 대기").font(.title2)
                                    }
                                case "ACTIVE":
                                    // 경매 진행 중: 종료 시간까지 카운트다운
                                    if let end = resolvedEndDate() {
                                        HStack(spacing: 4) {
                                            Text("경매 종료까지")
                                                .font(.subheadline)
                                                .foregroundStyle(Color.likeRed.opacity(0.8))
                                            CountdownText(endDate: normalizedAuctionEnd(end))
                                                .font(.title2)
                                        }
                                    } else {
                                        Text("진행 중").font(.title2)
                                    }
                                default:
                                    // 종료된 상태들: 상태 텍스트 표시
                                    Text(getAuctionStatusText()).font(.title2)
                                }
                            } else {
                                Text("상태 불명").font(.title2)
                            }
                        }
                        .foregroundStyle(
                            isAuctionEnded() ? Color.grey300 :
                            vm.liveAuction?.status == "ACTIVE" ? Color.likeRed : Color.blue
                        )
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
                            title: getAuctionButtonText(),
                            action: { 
                                if isAuctionStarted() && !isAuctionEnded() {
                                    showBidSheet = true 
                                }
                            },
                            fontSize: 16,
                            fontWeight: .semibold,
                            cornerRadius: 12,
                            horizontalPadding: 0,
                            foregroundColor: .white,
                            backgroundColor: isAuctionEnded() ? Color.grey300 :
                                           isAuctionStarted() ? brand : Color.grey300,
                            pressedBackgroundColor: isAuctionEnded() ? Color.grey300.opacity(0.85) :
                                                   isAuctionStarted() ? brand.opacity(0.85) : Color.grey300.opacity(0.85),
                            shadowColor: Color.black.opacity(0.1)
                        )
                        .disabled(!isAuctionStarted() || isAuctionEnded() || vm.liveAuction?.status == nil)
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

    private func resolvedStartDate() -> Date? {
        guard let startAt = vm.liveAuction?.startAt else {
            print("❌ 시작 시간이 없습니다")
            return nil
        }
        print("🕐 시작 시간 파싱 시도: \(startAt)")
        if let d = parseISO8601(startAt) {
            print("✅ 시작 시간 파싱 성공: \(d)")
            return d
        }
        print("❌ 시작 시간 파싱 실패")
        return nil
    }
    
    private func resolvedEndDate() -> Date? {
        guard let endAt = vm.liveAuction?.endAt else {
            print("❌ 종료 시간이 없습니다")
            return nil
        }
        print("🕐 종료 시간 파싱 시도: \(endAt)")
        if let d = parseISO8601(endAt) {
            print("✅ 종료 시간 파싱 성공: \(d)")
            return d
        }
        print("❌ 종료 시간 파싱 실패")
        return nil
    }
    
    private func parseISO8601(_ s: String) -> Date? {
        print("📅 날짜 파싱 시도: \(s)")
        
        // 1. ISO8601 포맷터로 시도 (시간대 포함)
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = iso.date(from: s) { 
            print("✅ ISO8601 (시간대 포함) 파싱 성공: \(d)")
            return d 
        }
        print("❌ ISO8601 (시간대 포함) 파싱 실패")
        
        iso.formatOptions = [.withInternetDateTime]
        if let d2 = iso.date(from: s) { 
            print("✅ ISO8601 (시간대 없음) 파싱 성공: \(d2)")
            return d2 
        }
        print("❌ ISO8601 (시간대 없음) 파싱 실패")
        
        // 2. Fallback: 시간대 없는 형식 (Firebase 형식)
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .iso8601)
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let d3 = df.date(from: s) {
            print("✅ Fallback (HH:mm:ss) 파싱 성공: \(d3)")
            return d3
        }
        print("❌ Fallback (HH:mm:ss) 파싱 실패")
        
        // 2-1. 시간이 HH:mm 형식인 경우 (startAt이 00:00인 경우)
        df.dateFormat = "yyyy-MM-dd'T'HH:mm"
        if let d3_1 = df.date(from: s) {
            print("✅ Fallback (HH:mm) 파싱 성공: \(d3_1)")
            return d3_1
        }
        print("❌ Fallback (HH:mm) 파싱 실패")
        
        // 3. 날짜만 있는 형식
        df.dateFormat = "yyyy-MM-dd"
        if let d4 = df.date(from: s) {
            print("✅ 날짜만 파싱 성공: \(d4)")
            return d4
        }
        print("❌ 날짜만 파싱 실패")
        
        print("❌ 모든 파싱 시도 실패")
        return nil
    }
    
    private func isAuctionStarted() -> Bool {
        guard let status = vm.liveAuction?.status else {
            print("⚠️ 경매 상태가 없습니다 - 시작된 것으로 간주")
            return true
        }
        
        let isStarted = status == "ACTIVE"
        
        print("🕐 경매 상태 체크")
        print("   - 경매 상태: \(status)")
        print("   - 경매 시작됨: \(isStarted)")
        
        return isStarted
    }
    
    private func isAuctionEnded() -> Bool {
        guard let status = vm.liveAuction?.status else {
            print("⚠️ 경매 상태가 없습니다 - 종료되지 않은 것으로 간주")
            return false
        }
        
        let isEnded = status == "ENDED" || 
                     status == "PENDING_CLOSE" || 
                     status == "CANCELLED" || 
                     status == "EXPIRED"
        
        print("🕐 경매 종료 상태 체크")
        print("   - 경매 상태: \(status)")
        print("   - 경매 종료됨: \(isEnded)")
        
        return isEnded
    }
    
    private func getAuctionStatusText() -> String {
        guard let status = vm.liveAuction?.status else {
            return "상태 불명"
        }
        
        switch status {
        case "UPCOMING":
            return "시작 대기"
        case "ACTIVE":
            return "진행 중"
        case "ENDED":
            return "경매 종료"
        case "PENDING_CLOSE":
            return "종료 처리 중"
        case "CANCELLED":
            return "경매 취소"
        case "EXPIRED":
            return "유찰됨"
        default:
            return "상태 불명"
        }
    }
    
    private func getAuctionButtonText() -> String {
        guard let status = vm.liveAuction?.status else {
            return "상태 불명"
        }
        
        switch status {
        case "UPCOMING":
            return "경매 시작 대기"
        case "ACTIVE":
            return "상위 입찰"
        case "ENDED":
            return "경매 종료"
        case "PENDING_CLOSE":
            return "종료 처리 중"
        case "CANCELLED":
            return "경매 취소"
        case "EXPIRED":
            return "유찰됨"
        default:
            return "상태 불명"
        }
    }

    
    private func submitBid(bidPrice: Int) async {
        guard let auctionId = detail.auctionId else {
            print("❌ 경매 ID가 없습니다")
            return
        }
        
        print("💰 경매 입찰 시작")
        print("   - AuctionId: \(auctionId)")
        print("   - BidPrice: \(bidPrice)")
        
        let success = await NetworkManager.shared.submitBid(
            auctionId: auctionId,
            bidPrice: bidPrice
        )
        
        if success {
            print("✅ 경매 입찰 성공")
            // TODO: 성공 알림 표시
        } else {
            print("❌ 경매 입찰 실패")
            // TODO: 실패 알림 표시
        }
    }
    
    private func toggleFavorite() {
        guard !isTogglingFavorite else { return }
        
        isTogglingFavorite = true
        
        Task {
            let result = await NetworkManager.shared.toggleFavorite(vehicleId: detail.id)
            
            await MainActor.run {
                isTogglingFavorite = false
                if let newFavoriteState = result {
                    // 전역 상태 업데이트
                    favoriteManager.toggleFavorite(vehicleId: detail.id, newState: newFavoriteState)
                }
            }
        }
    }
}

#Preview {
    NavigationStack { CarDetailScreen(vehicleId: 1) }
}
