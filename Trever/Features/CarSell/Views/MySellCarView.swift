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
