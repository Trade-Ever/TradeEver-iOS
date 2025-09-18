import SwiftUI

struct SearchView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var query: String = ""

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("모델, 옵션, 키워드로 검색", text: $query)
                    .textFieldStyle(.plain)
                Button("취소") { dismiss() }
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.grey50))
            .padding(.horizontal, 16)

            Spacer()
            ContentUnavailableView("검색 준비 중", systemImage: "car")
            Spacer()
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { SearchView() }
}

