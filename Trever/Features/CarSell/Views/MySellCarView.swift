//
//  MySellCarView.swift
//  Trever
//
//  Created by OhChangEun on 9/24/25.
//

import SwiftUI

struct MySellCarView: View {
    @StateObject private var viewModel = MySellCarViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                
                TopBannerView()
                
                // 섹션 헤더
                HStack {
                    Text("내가 등록한 차량")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color.grey400)
                    
                    Spacer()
                    
                    Text("\(viewModel.totalCount)대")
                        .font(.subheadline)
                        .foregroundColor(Color.grey300)
                }
                .padding(.top)
                .padding(.horizontal, 16)
            
            // 차량 리스트
            if viewModel.isLoading {
                // 로딩 상태
                VStack {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("내 차량을 불러오는 중...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.top, 16)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else if viewModel.myCars.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "car.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.gray.opacity(0.5))
                    
                    VStack(spacing: 8) {
                        Text("등록한 차량이 없습니다")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text("차량을 등록해보세요")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.bottom, 100)
            } else {
                // 차량 리스트
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(viewModel.myCars.enumerated()), id: \.element.id) { index, vehicle in
                            // 경매 아이템인지 확인하여 적절한 뷰 사용
                            if vehicle.isAuction == "Y" {
                                // Vehicle을 VehicleAPIItem으로 변환
                                let vehicleAPIItem = VehicleAPIItem(
                                    id: Int64(vehicle.id),
                                    carName: vehicle.carName,
                                    carNumber: vehicle.carNumber,
                                    manufacturer: vehicle.manufacturer,
                                    model: vehicle.model,
                                    year_value: vehicle.yearValue,
                                    mileage: vehicle.mileage,
                                    transmission: vehicle.transmission,
                                    vehicleStatus: vehicle.vehicleStatus,
                                    fuelType: vehicle.fuelType,
                                    price: vehicle.price,
                                    isAuction: vehicle.isAuction,
                                    representativePhotoUrl: vehicle.representativePhotoUrl,
                                    locationAddress: nil,
                                    favoriteCount: vehicle.favoriteCount,
                                    createdAt: vehicle.createdAt,
                                    vehicleTypeName: vehicle.vehicleTypeName,
                                    mainOptions: vehicle.mainOptions,
                                    totalOptionsCount: vehicle.totalOptionsCount,
                                    auctionId: vehicle.auctionId != nil ? Int64(vehicle.auctionId!) : nil,
                                    startPrice: nil,
                                    currentPrice: nil,
                                    startAt: nil,
                                    endAt: nil,
                                    auctionStatus: nil,
                                    bidCount: nil,
                                    isFavorite: vehicle.isFavorite
                                )
                                
                                NavigationLink(destination: CarDetailScreen(vehicleId: Int(vehicle.id))) {
                                    MySellCarAuctionItemView(
                                        vehicle: vehicleAPIItem
                                    )
                                }
                                .buttonStyle(.plain)
                                .onAppear {
                                    // 무한 스크롤
                                    if index == viewModel.myCars.count - 5 && viewModel.hasMoreData {
                                        Task {
                                            await viewModel.loadMoreCars()
                                        }
                                    }
                                }
                            } else {
                                NavigationLink {
                                    CarDetailScreen(vehicleId: Int(vehicle.id))
                                } label: {
                                    CarListItemView(vehicle: vehicle)
                                }
                                .buttonStyle(.plain)
                                .onAppear {
                                    // 무한 스크롤
                                    if index == viewModel.myCars.count - 5 && viewModel.hasMoreData {
                                        Task {
                                            await viewModel.loadMoreCars()
                                        }
                                    }
                                }
                            }
                        }
                        
                        // 더 많은 데이터 로딩 인디케이터
                        if viewModel.isLoadingMore {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .padding()
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .refreshable {
                    await viewModel.refreshCars()
                }
            }
        }
        .task {
            await viewModel.fetchMyCars()
        }
        }
    }
}

// MARK: - Firebase 연동 경매 아이템 뷰 (내차 팔기용)
struct MySellCarAuctionItemView: View {
    let vehicle: VehicleAPIItem
    
    @State private var liveAuction: AuctionLive? = nil
    @State private var auctionHandle: UInt? = nil
    
    var body: some View {
        AuctionCarListItemView(vehicle: vehicle, live: liveAuction)
            .onAppear {
                subscribeToAuction()
            }
            .onDisappear {
                unsubscribeFromAuction()
            }
    }
    
    // MARK: - Firebase Methods
    private func subscribeToAuction() {
        guard vehicle.isAuction == "Y" else { return }
        
        // vehicleId로 Firebase에서 경매 데이터 구독
        let handle = FirebaseAuctionService.shared.observeAuctionByVehicleIdContinuous(vehicleId: Int(vehicle.id)) { live in
            Task { @MainActor in
                self.liveAuction = live
            }
        }
        auctionHandle = handle
    }
    
    private func unsubscribeFromAuction() {
        guard let handle = auctionHandle else { return }
        
        // Firebase 구독 해제
        FirebaseAuctionService.shared.removeObserver(auctionId: Int(vehicle.id), handle: handle)
        auctionHandle = nil
    }
}
