import SwiftUI
import UIKit

private struct TabItem: Identifiable {
    let id = UUID()
    let tab: MainTab
    let title: String
    let base: String // expects ..._fill / ..._outlined
}

struct CustomTabBar: View {
    @Binding var selection: MainTab

    private let brand = Color.purple400
    private let unselected = Color.grey300 // light gray

    private var items: [TabItem] {
        [
            .init(tab: .buy,     title: "내차사기",  base: "buy_car"),
            .init(tab: .sell,    title: "내차팔기",  base: "cell_car"),
            .init(tab: .auction, title: "경매",     base: "auction"),
            .init(tab: .mypage,  title: "마이페이지", base: "mypage")
        ]
    }

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.black.opacity(0.08)) // 상단 헤어라인
                .frame(height: 0.5)

            HStack(spacing: 0) {
                ForEach(items) { item in
                    let isSelected = (selection == item.tab)
                    Button {
                        selection = item.tab
                    } label: {
                        VStack(spacing: 6) {
                            tabImage(named: item.base, selected: isSelected)
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundColor(isSelected ? brand : unselected)
                            Text(item.title)
                                .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                                .foregroundColor(isSelected ? brand : unselected)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24) // 내부 좌우 여백만 유지
            .background(Color(.systemBackground))
        }
        .background(Color(.systemBackground)) // 화면 끝까지 채움
    }

    private func tabImage(named base: String, selected: Bool) -> Image {
        let name = selected ? "\(base)_fill" : "\(base)_outlined"
        if UIImage(named: name) != nil { return Image(name) }
        switch base { // Fallback to SF Symbols
        case "buy_car": return Image(systemName: selected ? "car.fill" : "car")
        case "cell_car": return Image(systemName: selected ? "arrow.up.circle.fill" : "arrow.up.circle")
        case "auction": return Image(systemName: selected ? "hammer.fill" : "hammer")
        case "mypage": return Image(systemName: selected ? "person.crop.circle.fill" : "person.crop.circle")
        default: return Image(systemName: "circle")
        }
    }
}
