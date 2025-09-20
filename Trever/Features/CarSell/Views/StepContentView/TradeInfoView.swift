import SwiftUI

struct TradeInfoView: View {
    @Binding var tradeMethod: String
    @Binding var startDate: Date?
    @Binding var endDate: Date?
    @Binding var price: String
    
    @Binding var step: Int
    
    // FocusState
    enum Field: Hashable {
        case price
    }
    @FocusState private var focusedField: Field?
    
    // 거래 방식 버튼 배열
    let tradeOptions = ["경매", "일반거래"]
    
    var body: some View {
        VStack(spacing: 12) {
            
            // 1. 거래 방식 선택
            if step >= 0 {
                InputSection(title: "거래 방식을 선택해주세요") {
                    HStack(spacing: 16) {
                        ForEach(tradeOptions, id: \.self) { option in
                            SelectableButton(
                                title: option,
                                isSelected: tradeMethod == option,
                                action: {
                                    handleTradeMethodSelection(option)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 8)
                }
            }
            
            // 2. 거래 날짜 선택 (경매일 때만)
            if tradeMethod == "경매" && step >= 1 {
                InputSection(title: "거래 날짜를 선택해주세요") {
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            DatePickerButton(
                                title: "시작 날짜",
                                date: $startDate,
                                minimumDate: Date()
                            ) { selectedDate in
                                // 시작 날짜, 끝날짜 검사
                                if let end = endDate, selectedDate > end {
                                    endDate = selectedDate
                                }
                                checkDateCompletion()
                            }
                            
                            Text("~")
                                .foregroundStyle(Color.grey300)
                            
                            DatePickerButton(
                                title: "종료 날짜",
                                date: $endDate,
                                minimumDate: startDate ?? Date()
                            ) { _ in
                                // 단순화된 처리
                                checkDateCompletion()
                            }
                        }
                        
                        // 간단한 기간 표시
                        if let start = startDate, let end = endDate, end >= start {
                            let days = Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0
                            HStack(spacing: 0) {
                                Text("경매 기간: ")
                                    .font(.caption)
                                    .foregroundColor(.purple300)

                                Text("\(days + 1)일")
                                    .font(.caption)
                                    .fontWeight(.bold) // 숫자만 굵게
                                    .foregroundColor(.purple500)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                }
            } else if step >= 1 && tradeMethod == "일반거래" {
                // 일반거래일 때 빈 공간 확보 (경매 UI와 동일한 높이)
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 120) // 날짜 선택 UI와 유사한 높이
            }
            
            // 3. 제시 가격 입력
            if shouldShowPriceInput {
                Spacer()
                InputSection(title: "제시할 가격을 입력해주세요", subTitle: "(만원)") {
                    CustomInputBox(
                        inputType: .number,
                        placeholder: "3000",
                        height: 80,
                        text: $price
                    )
                    .focused($focusedField, equals: .price)
                    .font(.system(size: 36, weight: .bold))
                    .onSubmit {
                        focusedField = nil
                    }
                    .multilineTextAlignment(.trailing)
                }
            }
        }
    }
    
    // 단순화된 가격 입력 표시 조건
    private var shouldShowPriceInput: Bool {
        switch tradeMethod {
        case "일반거래":
            return step >= 2
        case "경매":
            return step >= 2 && startDate != nil && endDate != nil
        default:
            return false
        }
    }
    
    // 단순화된 거래 방식 선택 처리
    private func handleTradeMethodSelection(_ option: String) {
        tradeMethod = option
        
        switch option {
        case "경매":
            price = ""  // 가격 초기화
            withAnimation(.easeInOut(duration: 0.3)) {
                step = max(step, 1)
            }
            focusedField = nil
        case "일반거래":
            price = ""  // 가격 초기화
            withAnimation(.easeInOut(duration: 0.3)) {
                step = max(step, 2)
            }
            focusedField = .price
        default:
            break
        }
    }
    
    // 단순화된 날짜 완료 체크
    private func checkDateCompletion() {
        // 불필요한 검증 제거, 단순한 조건만 체크
        if startDate != nil && endDate != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    step = max(step, 2) // 가격 입력 단계로
                }
                focusedField = .price // 가격 입력 단계 강조
            }
        }
    }
}

struct TradeInfoView_Previews: PreviewProvider {
    @State static var tradeMethod = ""
    @State static var startDate: Date? = nil
    @State static var endDate: Date? = nil
    @State static var price = ""
    @State static var step = 0
    
    static var previews: some View {
        TradeInfoView(
            tradeMethod: $tradeMethod,
            startDate: $startDate,
            endDate: $endDate,
            price: $price,
            step: $step
        )
        .previewLayout(.sizeThatFits)
    }
}
