import SwiftUI

struct TransactionHistoryItem: View {
    let transaction: TransactionHistoryData
    let isSalesHistory: Bool
    let onTap: () -> Void
    let onPDFTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
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
            onTap()
        }
    }
}

// MARK: - Subviews
private extension TransactionHistoryItem {
    var infoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center) {
                Text(transaction.vehicleName)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Spacer()
                Text(Formatters.priceText(won: transaction.finalPrice))
                    .foregroundStyle(Color.priceGreen)
                    .font(.title2).bold()
            }

            Text("거래 상대: \(isSalesHistory ? transaction.buyerName : transaction.sellerName)")
                .foregroundStyle(.secondary)
                .font(.subheadline)

            Text(formatDate(transaction.createdAt))
                .foregroundStyle(.secondary)
                .font(.subheadline)

            if transaction.contractId != nil {
                HStack {
                    Spacer()
                    Button(action: onPDFTap) {
                        HStack {
                            Text("PDF 보기")
                            Image(systemName: "doc.text.fill")
                        }
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(width: 100)
                        .padding(.vertical, 10)
                        .background(Color.grey300.opacity(0.5))
                        .cornerRadius(8)
                    }
                }
            }
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "MM/dd"
            return displayFormatter.string(from: date)
        }
        
        return dateString
    }
}

#Preview {
    VStack(spacing: 12) {
        TransactionHistoryItem(
            transaction: TransactionHistoryData(
                transactionId: 66,
                vehicleId: 261,
                vehicleName: "쏘나타",
                buyerName: "채상윤",
                sellerName: "추추추",
                finalPrice: 100000,
                status: "COMPLETED",
                createdAt: "2025-09-23T11:53:33.839238",
                contractId: 66,
                contractPdfUrl: "/api/v1/contracts/66/pdf"
            ),
            isSalesHistory: true,
            onTap: { print("아이템 탭") },
            onPDFTap: { print("PDF 보기") }
        )
        
        TransactionHistoryItem(
            transaction: TransactionHistoryData(
                transactionId: 65,
                vehicleId: 132,
                vehicleName: "벨로스터",
                buyerName: "추추추",
                sellerName: "채상윤",
                finalPrice: 8000000,
                status: "COMPLETED",
                createdAt: "2025-09-23T11:33:01.704940",
                contractId: nil,
                contractPdfUrl: nil
            ),
            isSalesHistory: false,
            onTap: { print("아이템 탭") },
            onPDFTap: { print("PDF 보기") }
        )
    }
    .padding()
}
