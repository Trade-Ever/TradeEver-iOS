import SwiftUI

struct AuctionView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Image(systemName: "hammer")
                    .font(.system(size: 48, weight: .regular))
                Text("진행 중인 경매가 없습니다")
                    .font(.headline)
                Text("추가되면 여기에서 확인할 수 있어요.")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("경매")
        }
    }
}

#Preview { AuctionView() }

