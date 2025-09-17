import SwiftUI

struct MarkSoldSheet: View {
    let buyers: [PotentialBuyer]
    var onConfirm: ((String) -> Void)? = nil // selected buyer id

    private let brand = Color.purple400
    @State private var selectedId: String? = nil

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
                title: "구매자 선택하기",
                action: { if let id = selectedId { onConfirm?(id) } },
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
            .disabled(selectedId == nil)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
        }
    }
}

#Preview {
    MarkSoldSheet(buyers: [
        PotentialBuyer(id: "1", name: "홍길동"),
        PotentialBuyer(id: "2", name: "오창운"),
        PotentialBuyer(id: "3", name: "오창운")
    ]) { _ in }
}
