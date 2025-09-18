import SwiftUI

struct SearchBarButton: View {
    var title: String = "차량 검색"
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                Text(title)
                    .foregroundStyle(.secondary)
                    .font(.body)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color.grey50)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SearchBarButton(title: "차량 검색") {}
        .padding()
}

