import SwiftUI
import Foundation

struct AuctionCarListItemView: View {
    let vehicle: VehicleAPIItem
    let live: AuctionLive?
    
    // State
    @StateObject private var favoriteManager = FavoriteManager.shared
    @State private var isToggling = false
    
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
                .background(Color.secondaryBackground)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 0.5)
        )
        .contentShape(Rectangle())
        .onAppear {
            // 전역 상태에 초기 값 설정 (아직 설정되지 않은 경우에만)
            let vehicleId = Int(vehicle.id)
            if favoriteManager.favoriteStates[vehicleId] == nil {
                favoriteManager.setFavoriteState(vehicleId: vehicleId, isFavorite: vehicle.isFavorite ?? false)
            }
        }
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
                Capsule().fill(Color.errorRed)
            )
            .padding(8)
    }

    var likeButton: some View {
        Button {
            toggleFavorite()
        } label: {
            if isToggling {
                ProgressView()
                    .scaleEffect(0.8)
                    .foregroundStyle(.secondary)
            } else {
                let isLiked = favoriteManager.isFavorite(vehicleId: Int(vehicle.id))
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .foregroundStyle(isLiked ? Color.likeRed : .secondary)
                    .font(.system(size: 20, weight: .semibold))
            }
        }
        .padding(8)
        .disabled(isToggling)
    }
    
    private func toggleFavorite() {
        guard !isToggling else { return }
        
        isToggling = true
        
        Task {
            let result = await NetworkManager.shared.toggleFavorite(vehicleId: Int(vehicle.id))
            
            await MainActor.run {
                isToggling = false
                if let newFavoriteState = result {
                    // 전역 상태 업데이트
                    favoriteManager.toggleFavorite(vehicleId: Int(vehicle.id), newState: newFavoriteState)
                }
            }
        }
    }

    var infoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center) {
                Text(vehicle.manufacturer != nil && vehicle.model != nil ? "\(vehicle.manufacturer!) \(vehicle.model!)" : (vehicle.model ?? "차량"))
                    .font(.headline)
                    .foregroundStyle(Color.primaryText)
                Spacer()
                // 경매 상태별 시간 표시
                auctionTimeDisplay
            }

            Text("\(Formatters.yearText(vehicle.year_value ?? 0)) · \(Formatters.mileageText(km: vehicle.mileage ?? 0))")
                .foregroundStyle(Color.primaryText.opacity(0.7))
                .font(.subheadline)
            
            HStack {
                if let options = vehicle.mainOptions, !options.isEmpty {
                    tagsView(options: options)
                }
                Spacer()
                priceRow
            }
        }
    }

    func tagsView(options: [String]) -> some View {
        HStack(spacing: 5) {
            ForEach(Array(options.prefix(3)), id: \.self) { option in
                Text(option)
                    .font(.caption2)
                    .foregroundStyle(Color.secondaryText.opacity(0.7))
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
                        .foregroundStyle(Color.primaryText.opacity(0.7))
                        .font(.subheadline)
                } else {
                    Text("시작가 ")
                        .foregroundStyle(Color.primaryText.opacity(0.7))
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

    @ViewBuilder
    var auctionTimeDisplay: some View {
        if let status = getAuctionStatus() {
            switch status {
            case "UPCOMING":
                // 시작 대기: 시작 시간까지 카운트다운
                if let start = resolvedStartDate() {
                    HStack(spacing: 4) {
                        Image("gavel")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 16, height: 16)
                            .foregroundStyle(Color.primaryText)
                        HStack(spacing: 2) {
                            Text("시작까지")
                                .font(.caption)
                                .foregroundStyle(Color.blue.opacity(0.8))
                            CountdownText(endDate: start)
                                .font(.body).bold()
                        }
                    }
                    .foregroundStyle(Color.blue)
                } else {
                    HStack(spacing: 4) {
                        Image("gavel")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 16, height: 16)
                            .foregroundStyle(Color.primaryText)
                        Text("시작 대기")
                            .font(.body).bold()
                    }
                    .foregroundStyle(Color.blue)
                }
            case "ACTIVE":
                // 경매 진행 중: 종료 시간까지 카운트다운
                if let end = resolvedEndDate() {
                    HStack(spacing: 4) {
                        Image("gavel")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 16, height: 16)
                            .foregroundStyle(Color.primaryText)
                        HStack(spacing: 2) {
                            Text("종료까지")
                                .font(.caption)
                                .foregroundStyle(Color.likeRed.opacity(0.8))
                            CountdownText(endDate: normalizedAuctionEnd(end))
                                .font(.body).bold()
                        }
                    }
                    .foregroundStyle(Color.likeRed)
                } else {
                    HStack(spacing: 4) {
                        Image("gavel")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 16, height: 16)
                            .foregroundStyle(Color.primaryText)
                        Text("진행 중")
                            .font(.body).bold()
                    }
                    .foregroundStyle(Color.likeRed)
                }
            default:
                // 종료된 상태들: 상태 텍스트 표시
                HStack(spacing: 4) {
                    Image("gavel")
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 16, height: 16)
                        .foregroundStyle(Color.primaryText)
                    Text(getAuctionStatusText())
                        .font(.body).bold()
                }
                .foregroundStyle(Color.grey300)
            }
        }
    }
    
    private func getAuctionStatus() -> String? {
        // Priority: live.status -> vehicle.auctionStatus
        return live?.status ?? vehicle.auctionStatus
    }
    
    private func getAuctionStatusText() -> String {
        guard let status = getAuctionStatus() else { return "상태 불명" }
        switch status {
        case "UPCOMING": return "시작 대기"
        case "ACTIVE": return "진행 중"
        case "ENDED": return "경매 종료"
        case "PENDING_CLOSE": return "종료 처리 중"
        case "CANCELLED": return "경매 취소"
        case "EXPIRED": return "유찰됨"
        default: return "상태 불명"
        }
    }
    
    private func resolvedStartDate() -> Date? {
        // Priority: live.startAt -> vehicle.startAt
        if let s = live?.startAt, let d = parseISO8601(s) { return d }
        if let s = vehicle.startAt, let d = parseISO8601(s) { return d }
        return nil
    }
    
    private func resolvedEndDate() -> Date? {
        // Priority: live.endAt -> vehicle.endAt
        if let s = live?.endAt, let d = parseISO8601(s) { return d }
        if let s = vehicle.endAt, let d = parseISO8601(s) { return d }
        return nil
    }

    private func parseISO8601(_ s: String) -> Date? {
        // 1. ISO8601 포맷터로 시도 (시간대 포함)
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = iso.date(from: s) { return d }
        
        iso.formatOptions = [.withInternetDateTime]
        if let d2 = iso.date(from: s) { return d2 }
        
        // 2. Fallback: 시간대 없는 형식 (Firebase 형식)
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .iso8601)
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let d3 = df.date(from: s) { return d3 }
        
        // 2-1. 시간이 HH:mm 형식인 경우 (startAt이 00:00인 경우)
        df.dateFormat = "yyyy-MM-dd'T'HH:mm"
        if let d3_1 = df.date(from: s) { return d3_1 }
        
        // 3. 날짜만 있는 형식
        df.dateFormat = "yyyy-MM-dd"
        if let d4 = df.date(from: s) { return d4 }
        
        return nil
    }
}

#Preview {
    let preview = VehicleAPIItem(
        id: 115,
        carName: "BMW 520d",
        carNumber: "34나 5678",
        manufacturer: "BMW",
        model: "520d",
        year_value: 2020,
        mileage: 28500,
        transmission: "자동",
        vehicleStatus: "판매중",
        fuelType: "가솔린",
        price: nil,
        isAuction: "Y",
        representativePhotoUrl: "",
        locationAddress: "https://storage.googleapis.com/trever-ec541.firebasestorage.app/vehicles/1638692d-4ce6-4ad6-af58-c7cb15cfe429.jpg",
        favoriteCount: 0,
        createdAt: "2025-09-19T01:14:15.565347",
        vehicleTypeName: "중형",
        mainOptions: ["내비게이션", "썬루프", "어라운드뷰"],
        totalOptionsCount: 8,
        auctionId: 25000000,
        startPrice: 28000000,
        currentPrice: 10000000,
        startAt: "2025-09-25T23:59:59",
        endAt: "진행중",
        auctionStatus: "ACTIVE",
        bidCount: 4,
        isFavorite: false
    )
    return AuctionCarListItemView(vehicle: preview, live: nil).padding()
}
