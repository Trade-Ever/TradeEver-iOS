//
//  ColorInfoPage.swift
//  Trever
//
//  Created by OhChangEun on 9/16/25.
//

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
    
    // 날짜 포맷터
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy/MM/dd"
        return df
    }()
    
    // DatePicker 표시 상태
    @State private var showStartPicker = false
    @State private var showEndPicker = false
    
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
                                    tradeMethod = option
                                    // 선택하면 다음 step으로
                                    withAnimation(.easeInOut) { step = max(step, 1) }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 8)
                }
                .stepTransition(step: step, target: 0)
            }
            
            // 2. 거래 날짜 선택
            if step >= 1 {
                InputSection(title: "거래 날짜를 선택해주세요") {
                    HStack(spacing: 8) {
                        DatePickerButton(title: "시작 날짜", date: $startDate) { _ in
                            // 시작 날짜 선택 시 처리
                            // 두 날짜가 모두 선택되면 다음 step으로
                            if startDate != nil && endDate != nil {
                                withAnimation(.easeInOut) { step = max(step, 2) }
                                focusedField = .price
                            }
                        }
                        Text("~")
                            .foregroundStyle(Color.grey300)
                        DatePickerButton(title: "종료 날짜", date: $endDate) { _ in
                            // 종료 날짜 선택 시 처리
                            // 두 날짜가 모두 선택되면 다음 step으로
                            if startDate != nil && endDate != nil {
                                withAnimation(.easeInOut) { step = max(step, 2) }
                                focusedField = .price
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                }
                .stepTransition(step: step, target: 1)
            }
            
            // 3. 제시 가격 입력
            if step >= 2 {
                Spacer()
                InputSection(title: "제시할 가격을 입력해주세요", subTitle: "(만원)") {
                    CustomInputBox(
                        inputType: .number,
                        placeholder: "3000",
                        height: 80, // 조금 크게
                        text: $price
                    )
                    .focused($focusedField, equals: .price)
                    .font(.system(size: 32, weight: .bold))
                    .onSubmit {
                        focusedField = nil
                    }
                }
                .stepTransition(step: step, target: 2)
                .padding(.bottom, 12)
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
