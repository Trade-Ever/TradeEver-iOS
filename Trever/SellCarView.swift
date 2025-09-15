import SwiftUI

struct SellCarView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "car")
                    .font(.system(size: 56))
                Text("내 차량 정보를 등록해 보세요")
                    .font(.headline)
                Text("사진과 기본 정보를 입력하고 견적을 받아보세요.")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("내차팔기")
        }
    }
}

#Preview { SellCarView() }

