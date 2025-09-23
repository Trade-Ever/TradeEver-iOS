import SwiftUI

struct MarkSoldSheet: View {
    let buyers: [PotentialBuyer]
    let vehicleId: Int
    var onConfirm: ((String) -> Void)? = nil // selected buyer id
    var onTransactionComplete: (() -> Void)? = nil // 거래 완료 후 콜백

    private let brand = Color.purple400
    @State private var selectedId: String? = nil
    @State private var showTransactionComplete = false
    @State private var transactionData: TransactionCompleteData? = nil
    @State private var isSelecting = false
    @State private var errorMessage: String? = nil

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Text("구매자를 선택하세요")
                .font(.title3).bold()
                .padding(.horizontal, 20)
                .padding(.top, 36)

            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(buyers) { buyer in
                        Button(action: { selectedId = buyer.id }) {
                            HStack {
                                Spacer()
                                if selectedId == buyer.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(brand)
                                }
                                Text(buyer.name)
                                    .font(.title3).bold()
                                    .foregroundStyle(brand)
                                Spacer()
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedId == buyer.id ? brand.opacity(0.08) : Color.clear)
                            )
                        }
                        .frame(maxWidth: .infinity)
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100) // space for fixed CTA
            }
        }
        // Fixed bottom CTA that stays visible while list scrolls
        .safeAreaInset(edge: .bottom) {
            CustomButton(
                title: isSelecting ? "선택 중..." : "구매자 선택하기",
                action: { 
                    if let id = selectedId { 
                        selectBuyer(buyerId: id)
                    } 
                },
                fontSize: 16,
                fontWeight: .semibold,
                cornerRadius: 16,
                height: 54,
                horizontalPadding: 20,
                foregroundColor: .white,
                backgroundColor: brand,
                pressedBackgroundColor: brand.opacity(0.85),
                shadowColor: nil
            )
            .disabled(selectedId == nil || isSelecting)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
        }
        .sheet(isPresented: $showTransactionComplete) {
            if let transactionData = transactionData {
                TransactionCompleteView(
                    contractId: transactionData.contractId,
                    onComplete: {
                        // 거래 완료 후 모든 바텀시트 닫기
                        showTransactionComplete = false
                        onTransactionComplete?()
                    }
                )
            }
        }
        .alert("오류", isPresented: .constant(errorMessage != nil)) {
            Button("확인") {
                errorMessage = nil
            }
        } message: {
            if let errorMessage = errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    private func selectBuyer(buyerId: String) {
        guard let buyerIdInt = Int(buyerId) else {
            errorMessage = "잘못된 구매자 ID입니다."
            return
        }
        
        isSelecting = true
        
        Task {
            let result = await NetworkManager.shared.selectBuyer(vehicleId: vehicleId, buyerId: buyerIdInt)
            
            await MainActor.run {
                isSelecting = false
                
                if result.success, let data = result.data {
                    transactionData = data
                    showTransactionComplete = true
                } else {
                    errorMessage = result.message ?? "구매자 선택에 실패했습니다."
                }
            }
        }
    }
}

#Preview {
    MarkSoldSheet(
        buyers: [
            PotentialBuyer(id: "1", name: "홍길동"),
            PotentialBuyer(id: "2", name: "오창운"),
            PotentialBuyer(id: "3", name: "오창운")
        ],
        vehicleId: 132,
        onConfirm: {_ in 
            print("거래 완료 콜백 호출")
        }
    ) {  }
}
