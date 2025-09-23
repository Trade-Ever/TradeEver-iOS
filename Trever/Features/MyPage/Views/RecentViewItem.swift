//
//  RecentViewItem.swift
//  Trever
//
//  Created by 채상윤 on 9/23/25.
//

import SwiftUI

struct RecentViewItem: View {
    let vehicle: RecentViewData
    @State private var selectedVehicleId: Int? = nil
    @State private var showCarDetail = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                thumbnail
                    .frame(height: 180)
                    .clipped()

                statusBadge
            }

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
    }
}

// MARK: - Subviews
private extension RecentViewItem {
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
}

#Preview {
    VStack(spacing: 12) {
        RecentViewItem(
            vehicle: RecentViewData(
                id: 418,
                carName: "G70",
                carNumber: "12가1234",
                manufacturer: "제네시스",
                model: "G70SPORT",
                yearValue: 2019,
                mileage: 123,
                transmission: "자동",
                vehicleStatus: nil,
                fuelType: "휘발유",
                price: 12340000,
                isAuction: "N",
                auctionId: nil,
                representativePhotoUrl: "https://storage.googleapis.com/trever-ec541.firebasestorage.app/vehicles/52d6dcfd-88a0-4819-9705-13716b87bcdd.jpg",
                favoriteCount: 0,
                createdAt: "2025-09-23T18:36:33.579112",
                isFavorite: nil,
                vehicleTypeName: nil,
                mainOptions: nil,
                totalOptionsCount: nil
            )
        )
        
        RecentViewItem(
            vehicle: RecentViewData(
                id: 381,
                carName: "기아 스포티지",
                carNumber: "34바 5678",
                manufacturer: "기아",
                model: "스포티지",
                yearValue: 2011,
                mileage: 70000,
                transmission: "자동",
                vehicleStatus: nil,
                fuelType: "휘발유",
                price: 10000000,
                isAuction: "Y",
                auctionId: 161,
                representativePhotoUrl: nil,
                favoriteCount: 3,
                createdAt: "2025-09-23T17:48:08.186901",
                isFavorite: nil,
                vehicleTypeName: nil,
                mainOptions: nil,
                totalOptionsCount: nil
            )
        )
    }
    .padding()
}
