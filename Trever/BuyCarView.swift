import SwiftUI

struct BuyCarView: View {
    var body: some View {
        NavigationStack {
            List {
                Section(footer: Text("목업 데이터")) {
                    ForEach(0..<5) { _ in
                        VStack(alignment: .leading, spacing: 8) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.secondary.opacity(0.15))
                                .frame(height: 160)
                            Text("Torress EVX E7")
                                .font(.headline)
                            HStack {
                                Text("2024식 · 3.8만km")
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text("3,300만원")
                                    .foregroundStyle(.green)
                                    .fontWeight(.semibold)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("내차사기")
            .toolbar { ToolbarItem(placement: .topBarLeading) { Text("") } }
        }
    }
}

#Preview { BuyCarView() }

