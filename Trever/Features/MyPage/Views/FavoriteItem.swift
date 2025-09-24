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
                .background(Color.secondaryBackground)
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
            // 차량명과 가격
            HStack(alignment: .center) {
                Text(vehicle.carName)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Spacer()
                if let price = vehicle.price {
                    Text(Formatters.priceText(won: price))
                        .foregroundStyle(Color.priceGreen)
                        .font(.title2).bold()
                } else {
                    Text("가격 미정")
                        .foregroundStyle(.secondary)
                        .font(.title2).bold()
                }
            }

            // 차량 정보
            Text("\(vehicle.manufacturer) \(vehicle.model)")
                .foregroundStyle(.secondary)
                .font(.subheadline)

            // 연식과 주행거리
            Text("\(vehicle.yearValue)년 • \(vehicle.mileage.formatted())km")
                .foregroundStyle(.secondary)
                .font(.subheadline)

            // 연료타입과 변속기
            Text("\(vehicle.fuelType) • \(vehicle.transmission)")
                .foregroundStyle(.secondary)
                .font(.subheadline)
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
