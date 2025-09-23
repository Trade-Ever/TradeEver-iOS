import SwiftUI

struct AuctionBidSheet: View {
    let currentPriceWon: Int
    let startPriceWon: Int?
    var onConfirm: ((Int, Int) -> Void)? = nil // (incrementMan, newPriceWon)

    private let brand = Color.purple400
    @State private var incrementMan: Int // 만원 단위
    @FocusState private var focused: Bool

    // 현재 입찰가가 시작가와 같으면 시작가부터 입찰 가능, 아니면 최소 1만원 이상
    private var isFirstBid: Bool {
        guard let startPrice = startPriceWon else { return false }
        return currentPriceWon == startPrice
    }
    
    private var newPriceWon: Int {
        if isFirstBid {
            return startPriceWon! + (incrementMan * 10_000)
        } else {
            return currentPriceWon + (incrementMan * 10_000)
        }
    }
    
    private var buttonTitle: String {
        isFirstBid ? "입찰하기" : "상위 입찰"
    }
    
    // 초기화
    init(currentPriceWon: Int, startPriceWon: Int?, onConfirm: ((Int, Int) -> Void)? = nil) {
        self.currentPriceWon = currentPriceWon
        self.startPriceWon = startPriceWon
        self.onConfirm = onConfirm
        
        // 첫 입찰인 경우 0, 아니면 1로 초기화
        let isFirst = startPriceWon != nil && currentPriceWon == startPriceWon
        self._incrementMan = State(initialValue: isFirst ? 0 : 1)
    }

    var body: some View {
        Spacer()
        VStack(alignment: .leading, spacing: 16) {
            // Header prices
            VStack(alignment: .leading, spacing: 6) {
                if let start = startPriceWon {
                    Text("시작가 \(Formatters.priceText(won: start))")
                        .font(.title3).bold()
                        .foregroundStyle(Color.grey200)
                        .padding(.top, 2)
                }
                Text("현재가 \(Formatters.priceText(won: currentPriceWon))")
                    .font(.title3).bold()
                    .foregroundStyle(Color.grey300)
                Text(Formatters.priceText(won: newPriceWon))
                    .font(.title).bold()
                    .foregroundStyle(Color.priceGreen)
            }

            // Input row
            HStack(spacing: 12) {
                HStack {
                    TextField("1", value: $incrementMan, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .focused($focused)
                        .frame(minWidth: 24)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 10)
                        .onChange(of: incrementMan) { _, newValue in
                            if newValue < 0 { incrementMan = 0 }
                            if newValue > 1000000 { incrementMan = 1000000 }
                        }
                    Text("만원").foregroundStyle(.secondary)
                }
                .padding(.horizontal, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.grey100, lineWidth: 1)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)))
                )

                Spacer(minLength: 8)

                Button { 
                    if incrementMan > 0 { incrementMan -= 1 } 
                } label: {
                    Circle().fill(Color.grey50)
                        .overlay(Image(systemName: "minus").foregroundStyle(.secondary))
                        .frame(width: 36, height: 36)
                }
                Button { incrementMan += 1 } label: {
                    Circle().fill(Color.grey50)
                        .overlay(Image(systemName: "plus").foregroundStyle(.secondary))
                        .frame(width: 36, height: 36)
                }
            }

            // Confirm button
            CustomButton(
                title: buttonTitle,
                action: { onConfirm?(incrementMan, newPriceWon) },
                fontSize: 16,
                fontWeight: .semibold,
                cornerRadius: 16,
                height: 54,
                horizontalPadding: 0,
                foregroundColor: .white,
                backgroundColor: brand,
                pressedBackgroundColor: brand.opacity(0.85),
                shadowColor: nil
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 12)
//        .background(Color(.systemBackground))
    }
}

#Preview {
    AuctionBidSheet(currentPriceWon: 125_000_000, startPriceWon: 105_000_000)
}

