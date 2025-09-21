import SwiftUI

struct TransactionHistoryDetailView: View {
    @State private var selectedTab: TransactionTab = .sales
    
    init(initialTab: TransactionTab = .sales) {
        self._selectedTab = State(initialValue: initialTab)
    }
    
    enum TransactionTab: String, CaseIterable {
        case sales = "판매 내역"
        case purchases = "구매 내역"
        
        var title: String {
            return self.rawValue
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 탭 선택기
            tabSelector
            
            // 컨텐츠
            TabView(selection: $selectedTab) {
                SalesHistoryView()
                    .tag(TransactionTab.sales)
                
                PurchaseHistoryView()
                    .tag(TransactionTab.purchases)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .navigationTitle("거래 내역")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(TransactionTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 8) {
                        Text(tab.title)
                            .font(.headline)
                            .foregroundColor(selectedTab == tab ? .primary : .secondary)
                        
                        Rectangle()
                            .fill(selectedTab == tab ? Color.purple400 : Color.clear)
                            .frame(height: 2)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
}

// MARK: - 판매 내역 뷰
struct SalesHistoryView: View {
    @StateObject private var viewModel = SalesHistoryViewModel()
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if viewModel.isLoading {
                    ProgressView("로딩 중...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 100)
                } else if viewModel.transactions.isEmpty {
                    emptyState
                } else {
                    ForEach(viewModel.transactions) { transaction in
                        SalesTransactionItemView(transaction: transaction)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
        .refreshable {
            await viewModel.loadSalesHistory()
        }
        .onAppear {
            Task {
                await viewModel.loadSalesHistory()
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "car")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("판매 내역이 없습니다")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("차량을 판매하시면 여기에 표시됩니다")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
}

// MARK: - 구매 내역 뷰
struct PurchaseHistoryView: View {
    @StateObject private var viewModel = PurchaseHistoryViewModel()
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if viewModel.isLoading {
                    ProgressView("로딩 중...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 100)
                } else if viewModel.transactions.isEmpty {
                    emptyState
                } else {
                    ForEach(viewModel.transactions) { transaction in
                        PurchaseTransactionItemView(transaction: transaction)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
        .refreshable {
            await viewModel.loadPurchaseHistory()
        }
        .onAppear {
            Task {
                await viewModel.loadPurchaseHistory()
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "cart")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("구매 내역이 없습니다")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("차량을 구매하시면 여기에 표시됩니다")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
}

// MARK: - 거래 내역 모델
struct SalesTransaction: Identifiable, Hashable {
    let id = UUID()
    let vehicleId: Int64
    let vehicleName: String
    let vehicleImage: String?
    let price: Int
    let status: TransactionStatus
    let soldAt: Date?
    let buyerName: String?
    let createdAt: Date
}

struct PurchaseTransaction: Identifiable, Hashable {
    let id = UUID()
    let vehicleId: Int64
    let vehicleName: String
    let vehicleImage: String?
    let price: Int
    let status: TransactionStatus
    let purchasedAt: Date?
    let sellerName: String?
    let createdAt: Date
}

enum TransactionStatus: String, CaseIterable {
    case pending = "진행중"
    case completed = "완료"
    case cancelled = "취소"
    
    var color: Color {
        switch self {
        case .pending: return .orange
        case .completed: return .green
        case .cancelled: return .red
        }
    }
}

// MARK: - 거래 내역 아이템 뷰
struct SalesTransactionItemView: View {
    let transaction: SalesTransaction
    
    var body: some View {
        HStack(spacing: 12) {
            // 차량 이미지
            AsyncImage(url: URL(string: transaction.vehicleImage ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "car")
                            .foregroundColor(.gray)
                    )
            }
            .frame(width: 80, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.vehicleName)
                    .font(.headline)
                    .lineLimit(1)
                
                Text("판매가: \(Formatters.priceText(won: transaction.price))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let buyerName = transaction.buyerName {
                    Text("구매자: \(buyerName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text(transaction.status.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(transaction.status.color.opacity(0.2))
                        )
                        .foregroundColor(transaction.status.color)
                    
                    Spacer()
                    
                    Text(Formatters.dateText(transaction.createdAt))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.08), lineWidth: 0.5)
        )
    }
}

struct PurchaseTransactionItemView: View {
    let transaction: PurchaseTransaction
    
    var body: some View {
        HStack(spacing: 12) {
            // 차량 이미지
            AsyncImage(url: URL(string: transaction.vehicleImage ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "car")
                            .foregroundColor(.gray)
                    )
            }
            .frame(width: 80, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.vehicleName)
                    .font(.headline)
                    .lineLimit(1)
                
                Text("구매가: \(Formatters.priceText(won: transaction.price))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let sellerName = transaction.sellerName {
                    Text("판매자: \(sellerName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text(transaction.status.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(transaction.status.color.opacity(0.2))
                        )
                        .foregroundColor(transaction.status.color)
                    
                    Spacer()
                    
                    Text(Formatters.dateText(transaction.createdAt))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.08), lineWidth: 0.5)
        )
    }
}

// MARK: - ViewModels
@MainActor
class SalesHistoryViewModel: ObservableObject {
    @Published var transactions: [SalesTransaction] = []
    @Published var isLoading = false
    
    func loadSalesHistory() async {
        isLoading = true
        // TODO: 실제 API 호출로 판매 내역 데이터 로드
        // 임시 데이터
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1초 대기
        transactions = []
        isLoading = false
    }
}

@MainActor
class PurchaseHistoryViewModel: ObservableObject {
    @Published var transactions: [PurchaseTransaction] = []
    @Published var isLoading = false
    
    func loadPurchaseHistory() async {
        isLoading = true
        // TODO: 실제 API 호출로 구매 내역 데이터 로드
        // 임시 데이터
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1초 대기
        transactions = []
        isLoading = false
    }
}

#Preview {
    NavigationView {
        TransactionHistoryDetailView()
    }
}
