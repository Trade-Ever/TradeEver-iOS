import SwiftUI

struct WalletWithdrawView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedAmount: Int? = nil
    @State private var customAmount: String = ""
    @State private var isProcessing = false
    @State private var showingSuccessAlert = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @State private var currentBalance: Int = 0
    
    private let predefinedAmounts = [2000000, 1000000, 500000, 300000, 100000]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    Text("얼마나 출금할까요?")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    // Current Balance Info
                    HStack(spacing: 12) {
                        // Wallet Icon
                        Circle()
                            .fill(Color.purple400)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "creditcard")
                                    .font(.title3)
                                    .foregroundColor(.white)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("현재 잔액")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text("\(currentBalance.formatted())원")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(16)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Spacer()
                
                // Amount Selection
                VStack(spacing: 16) {
                    // Predefined amounts
                    VStack(spacing: 12) {
                        ForEach(predefinedAmounts, id: \.self) { amount in
                            Button(action: {
                                if amount <= currentBalance {
                                    selectedAmount = amount
                                    customAmount = ""
                                }
                            }) {
                                HStack {
                                    Text(amount.formatted() + "원")
                                        .font(.subheadline)
                                        .foregroundColor(
                                            amount <= currentBalance 
                                                ? (selectedAmount == amount ? .white : .primary)
                                                : .secondary
                                        )
                                    Spacer()
                                    if amount > currentBalance {
                                        Text("잔액 부족")
                                            .font(.caption)
                                            .foregroundColor(.red)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 24)
                                .background(
                                    selectedAmount == amount ? Color.purple400 : Color(.secondarySystemBackground)
                                )
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(
                                            amount <= currentBalance 
                                                ? (selectedAmount == amount ? Color.clear : Color(.separator))
                                                : Color.red.opacity(0.5), 
                                            lineWidth: 1
                                        )
                                )
                            }
                            .disabled(amount > currentBalance)
                        }
                    }
                    
                    // Custom input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("직접 입력하기")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        CustomInputBox(
                            inputType: .number,
                            placeholder: "금액을 입력하세요",
                            text: $customAmount
                        )
                        .onChange(of: customAmount) { newValue in
                            if !newValue.isEmpty {
                                selectedAmount = nil
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Action Button
                Button(action: {
                    performWithdraw()
                }) {
                    HStack {
                        if isProcessing {
                            ProgressView()
                                .scaleEffect(0.8)
                                .foregroundColor(Color.primaryText)
                        }
                        Text("출금하기")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.primaryText)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(
                        (selectedAmount != nil || !customAmount.isEmpty) ? Color.purple400 : Color(.tertiarySystemBackground)
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(selectedAmount == nil && customAmount.isEmpty || isProcessing)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("출금")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadCurrentBalance()
        }
        .alert("출금 완료", isPresented: $showingSuccessAlert) {
            Button("확인") {
                dismiss()
            }
        } message: {
            Text("출금이 완료되었습니다.")
        }
        .alert("출금 실패", isPresented: $showingErrorAlert) {
            Button("확인") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func loadCurrentBalance() {
        Task {
            if let balance = await NetworkManager.shared.fetchWalletBalance() {
                await MainActor.run {
                    self.currentBalance = balance
                }
            }
        }
    }
    
    private func performWithdraw() {
        let amount: Int
        
        if let selected = selectedAmount {
            amount = selected
        } else if let custom = Int(customAmount) {
            amount = custom
        } else {
            return
        }
        
        // 잔액 확인
        if amount > currentBalance {
            errorMessage = "잔액이 부족합니다."
            showingErrorAlert = true
            return
        }
        
        isProcessing = true
        
        Task {
            let success = await NetworkManager.shared.withdrawWallet(amount: amount)
            
            await MainActor.run {
                isProcessing = false
                if success {
                    showingSuccessAlert = true
                } else {
                    errorMessage = "출금에 실패했습니다. 다시 시도해주세요."
                    showingErrorAlert = true
                }
            }
        }
    }
}

#Preview {
    WalletWithdrawView()
}
