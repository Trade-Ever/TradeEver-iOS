//
//  TransactionHistoryView.swift
//  Trever
//
//  Created by 채상윤 on 9/23/25.
//

import SwiftUI

struct TransactionHistoryView: View {
    let isSalesHistory: Bool // true: 판매내역, false: 구매내역
    @State private var transactions: [TransactionHistoryData] = []
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    @State private var showTransactionComplete = false
    @State private var selectedTransaction: TransactionHistoryData? = nil
    @State private var selectedVehicleId: Int? = nil
    @State private var showCarDetail = false
    
    var title: String {
        isSalesHistory ? "판매내역" : "구매내역"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.2)
                        .progressViewStyle(CircularProgressViewStyle(tint: .purple400))
                    
                    Text("\(title)을 불러오는 중...")
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
                            await loadTransactions()
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
            } else if transactions.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: isSalesHistory ? "car.circle" : "cart.circle")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("\(title)이 없습니다")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(isSalesHistory ? "아직 판매한 차량이 없습니다" : "아직 구매한 차량이 없습니다")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(transactions) { transaction in
                            TransactionHistoryItem(
                                transaction: transaction,
                                isSalesHistory: isSalesHistory,
                                onTap: {
                                    selectedVehicleId = transaction.vehicleId
                                    showCarDetail = true
                                },
                                onPDFTap: {
                                    if let contractId = transaction.contractId {
                                        selectedTransaction = transaction
                                        showTransactionComplete = true
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }
            }
        }
        .onAppear {
            Task {
                await loadTransactions()
            }
        }
        .sheet(isPresented: $showTransactionComplete) {
            if let transaction = selectedTransaction,
               let contractId = transaction.contractId {
                TransactionCompleteView(
                    contractId: contractId,
                    onComplete: nil
                )
            } else {
                Text("데이터를 불러올 수 없습니다.")
            }
        }
        .navigationDestination(isPresented: $showCarDetail) {
            if let vehicleId = selectedVehicleId {
                CarDetailScreen(vehicleId: vehicleId)
            }
        }
    }
    
    private func loadTransactions() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result: [TransactionHistoryData]?
            
            if isSalesHistory {
                result = await NetworkManager.shared.fetchSalesHistory()
            } else {
                result = await NetworkManager.shared.fetchPurchaseHistory()
            }
            
            await MainActor.run {
                if let result = result {
                    self.transactions = result
                } else {
                    self.errorMessage = "\(title)을 불러올 수 없습니다."
                }
                self.isLoading = false
            }
        }
    }
}

#Preview {
    TransactionHistoryView(isSalesHistory: true)
}

