//
//  FavoriteItem.swift
//  Trever
//
//  Created by 채상윤 on 9/23/25.
//

import SwiftUI

struct FavoriteItem: View {
    let vehicle: FavoriteData
    @State private var selectedVehicleId: Int? = nil
    @State private var showCarDetail = false
    @StateObject private var favoriteManager = FavoriteManager.shared
    @State private var isToggling = false
    @State private var liveAuction: AuctionLive? = nil
    @State private var auctionHandle: UInt? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            GeometryReader { geometry in
                ZStack(alignment: .topLeading) {
                    thumbnail
                        .frame(width: geometry.size.width, height: 180)
                        .clipped()

                    statusBadge

                    HStack { Spacer(); likeButton }
                        .buttonStyle(.plain)
                        .padding(4)
                }
            }
            .frame(height: 180)

            infoSection
                .padding(12)
                .background(Color("cardBackground"))
        }
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            selectedVehicleId = vehicle.id
            showCarDetail = true
        }
        .navigationDestination(isPresented: $showCarDetail) {
            if let vehicleId = selectedVehicleId {
                CarDetailScreen(vehicleId: vehicleId)
            }
        }
        .onAppear {
            // 전역 상태에 초기 값 설정 (아직 설정되지 않은 경우에만)
            let vehicleId = Int(vehicle.id)
            if favoriteManager.favoriteStates[vehicleId] == nil {
                favoriteManager.setFavoriteState(vehicleId: vehicleId, isFavorite: vehicle.isFavorite ?? true)
            }
            
            // 경매 아이템인 경우 Firebase 구독
            if vehicle.isAuction == "Y" {
                subscribeToAuction()
            }
        }
        .onDisappear {
            if vehicle.isAuction == "Y" {
                unsubscribeFromAuction()
            }
        }
    }
}

// MARK: - Subviews
private extension FavoriteItem {
    @ViewBuilder
    var thumbnail: some View {
        if let photoUrl = vehicle.representativePhotoUrl, !photoUrl.isEmpty {
            AsyncImage(url: URL(string: photoUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.secondary.opacity(0.15))
                    .overlay(
                        Image(systemName: "car.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                    )
            }
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

    @ViewBuilder
    var statusBadge: some View {
        if vehicle.isAuction == "Y" {
            HStack {
                Text("경매")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.errorRed)
                    .cornerRadius(4)
                
                Spacer()
            }
            .padding(8)
        } else {
            EmptyView()
        }
    }

    var infoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center) {
                Text(vehicle.carName)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Spacer()
                // 경매 상태별 시간 표시
                if vehicle.isAuction == "Y" {
                    auctionTimeDisplay
                }
            }

            Text("\(vehicle.yearValue)년 • \(Formatters.mileageText(km: vehicle.mileage))")
                .foregroundStyle(.secondary)
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
                    .foregroundStyle(.secondary)
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
            let priceToShow = liveAuction?.currentBidPrice ?? liveAuction?.startPrice ?? vehicle.price
            if let price = priceToShow, price > 0 {
                if liveAuction?.currentBidPrice != nil {
                    Text("현재 입찰가 ")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                } else {
                    Text("시작가 ")
                        .foregroundStyle(.secondary)
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
            case "ENDED", "COMPLETED":
                // 경매 종료
                HStack(spacing: 4) {
                    Image("gavel")
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 16, height: 16)
                        .foregroundStyle(Color.primaryText)
                    Text("경매 종료")
                        .font(.body).bold()
                }
                .foregroundStyle(.secondary)
            default:
                // 기타 상태
                HStack(spacing: 4) {
                    Image("gavel")
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 16, height: 16)
                        .foregroundStyle(Color.primaryText)
                    Text(getAuctionStatusText())
                        .font(.body).bold()
                }
                .foregroundStyle(.secondary)
            }
        } else {
            // Firebase 데이터 로딩 중
            HStack(spacing: 4) {
                Image("gavel")
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 16, height: 16)
                    .foregroundStyle(Color.primaryText)
                Text("경매 정보 로딩 중...")
                    .font(.body).bold()
            }
            .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Helper Methods
    private func getAuctionStatus() -> String? {
        // Priority: live.status -> vehicle.isAuction
        return liveAuction?.status ?? (vehicle.isAuction == "Y" ? "ACTIVE" : nil)
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
        // Priority: live.startAt
        if let s = liveAuction?.startAt, let d = parseISO8601(s) { return d }
        return nil
    }
    
    private func resolvedEndDate() -> Date? {
        // Priority: live.endAt
        if let e = liveAuction?.endAt, let d = parseISO8601(e) { return d }
        return nil
    }
    
    private func parseISO8601(_ dateString: String) -> Date? {
        // 1. ISO8601 포맷터로 시도 (시간대 포함)
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = iso.date(from: dateString) { return d }
        
        iso.formatOptions = [.withInternetDateTime]
        if let d2 = iso.date(from: dateString) { return d2 }
        
        // 2. 기본 DateFormatter로 시도
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "UTC")
        if let d3 = formatter.date(from: dateString) { return d3 }
        
        // 3. 마지막 시도: 로컬 시간대
        formatter.timeZone = TimeZone.current
        return formatter.date(from: dateString)
    }
    
    private func normalizedAuctionEnd(_ end: Date) -> Date {
        // AuctionCarListItemView와 동일한 로직
        let now = Date()
        return max(end, now.addingTimeInterval(60)) // 최소 1분 후
    }
    
    // MARK: - Firebase Methods
    private func subscribeToAuction() {
        guard vehicle.isAuction == "Y" else { return }
        
        // vehicleId로 Firebase에서 경매 데이터 구독
        let handle = FirebaseAuctionService.shared.observeAuctionByVehicleIdContinuous(vehicleId: vehicle.id) { live in
            Task { @MainActor in
                self.liveAuction = live
            }
        }
        auctionHandle = handle
    }
    
    private func unsubscribeFromAuction() {
        guard let handle = auctionHandle else { return }
        
        // Firebase 구독 해제
        FirebaseAuctionService.shared.removeObserver(auctionId: vehicle.id, handle: handle)
        auctionHandle = nil
    }
}

#Preview {
    VStack(spacing: 12) {
        FavoriteItem(
            vehicle: FavoriteData(
                id: 401,
                carName: "렉서스 ES300h",
                carNumber: "78휘 1234",
                manufacturer: "렉서스",
                model: "ES300h",
                yearValue: 2020,
                mileage: 42000,
                transmission: "자동",
                vehicleStatus: nil,
                fuelType: "휘발유",
                price: nil,
                isAuction: "Y",
                auctionId: 109,
                representativePhotoUrl: nil,
                favoriteCount: 3,
                createdAt: "2025-09-23T17:54:52.236324",
                isFavorite: nil,
                vehicleTypeName: nil,
                mainOptions: nil,
                totalOptionsCount: nil
            )
        )
        
        FavoriteItem(
            vehicle: FavoriteData(
                id: 258,
                carName: "라세티",
                carNumber: "1234",
                manufacturer: "쉐보레",
                model: "라세티",
                yearValue: 2011,
                mileage: 12345,
                transmission: "자동",
                vehicleStatus: nil,
                fuelType: "휘발유",
                price: 123450000,
                isAuction: "N",
                auctionId: nil,
                representativePhotoUrl: "https://storage.googleapis.com/trever-ec541.firebasestorage.app/vehicles/bde1f08d-87e4-4039-a4a5-1a45cc1ed44d.jpg",
                favoriteCount: 1,
                createdAt: "2025-09-23T11:43:34.007277",
                isFavorite: nil,
                vehicleTypeName: nil,
                mainOptions: nil,
                totalOptionsCount: nil
            )
        )
    }
    .padding()
}
