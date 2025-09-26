import SwiftUI

struct WalletDepositView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedAmount: Int? = nil
    @State private var customAmount: String = ""
    @State private var isProcessing = false
    @State private var showingSuccessAlert = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    
    private let predefinedAmounts = [2000000, 1000000, 500000, 300000, 100000]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    Text("얼마나 충전할까요?")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.primaryText)
                    
                    // Bank Account Info
                    HStack(spacing: 12) {
                        // Bank Logo (placeholder)
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text("우")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.primaryText)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("우리은행")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(Color.primaryText)
                            Text("1002-044-***** 에서")
                                .font(.caption)
                                .foregroundColor(Color.primaryText)
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
                                selectedAmount = amount
                                customAmount = ""
                            }) {
                                HStack {
                                    Text(amount.formatted() + "원")
                                        .font(.subheadline)
                                        .foregroundColor(selectedAmount == amount ? .white : .primary)
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 24)
                                .background(
                                    selectedAmount == amount ? Color.purple400 : Color(.secondarySystemBackground)
                                )
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(selectedAmount == amount ? Color.clear : Color(.separator), lineWidth: 1)
                                )
                            }
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
                        .onChange(of: customAmount) { _, newValue in
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
                    performDeposit()
                }) {
                    HStack {
                        if isProcessing {
                            ProgressView()
                                .scaleEffect(0.8)
                                .foregroundColor(Color.primaryText)
                        }
                        Text("충전하기")
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
            .navigationTitle("충전")
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
        .alert("충전 완료", isPresented: $showingSuccessAlert) {
            Button("확인") {
                dismiss()
            }
        } message: {
            Text("충전이 완료되었습니다.")
        }
        .alert("충전 실패", isPresented: $showingErrorAlert) {
            Button("확인") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func performDeposit() {
        let amount: Int
        
        if let selected = selectedAmount {
            amount = selected
        } else if let custom = Int(customAmount) {
            amount = custom
        } else {
            return
        }
        
        isProcessing = true
        
        Task {
            let success = await NetworkManager.shared.depositWallet(amount: amount)
            
            await MainActor.run {
                isProcessing = false
                if success {
                    showingSuccessAlert = true
                } else {
                    errorMessage = "충전에 실패했습니다. 다시 시도해주세요."
                    showingErrorAlert = true
                }
            }
        }
    }
}

#Preview {
    WalletDepositView()
}
