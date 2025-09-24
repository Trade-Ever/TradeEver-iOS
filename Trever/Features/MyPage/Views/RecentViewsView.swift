//
//  RecentViewsView.swift
//  Trever
//
//  Created by 채상윤 on 9/23/25.
//

import SwiftUI

struct RecentViewsView: View {
    @State private var vehicles: [RecentViewData] = []
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.2)
                        .progressViewStyle(CircularProgressViewStyle(tint: .purple400))
                    
                    Text("최근 본 차량을 불러오는 중...")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage = errorMessage {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                    
                    Text("오류가 발생했습니다")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(errorMessage)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button("다시 시도") {
                        Task {
                            await loadRecentViews()
                        }
                    }
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if vehicles.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "clock.circle")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("최근 본 차량이 없습니다")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("차량을 둘러보시면 여기에 표시됩니다")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(vehicles) { vehicle in
                            RecentViewItem(vehicle: vehicle)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }
            }
        }
        .onAppear {
            Task {
                await loadRecentViews()
            }
        }
    }
    
    private func loadRecentViews() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = await NetworkManager.shared.fetchRecentViews()
            
            await MainActor.run {
                if let result = result {
                    self.vehicles = result
                } else {
                    self.errorMessage = "최근 본 차량을 불러올 수 없습니다."
                }
                self.isLoading = false
            }
        }
    }
}

#Preview {
    RecentViewsView()
}
