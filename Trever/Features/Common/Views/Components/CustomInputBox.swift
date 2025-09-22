//
//  CustomInputBox.swift
//  Trever
//
//  Created by OhChangEun on 9/16/25.
//

import SwiftUI

/***
 아래와 같이 사용
 
 InputBox(placeholder: "아이디 입력")
 InputBox(placeholder: "비밀번호 입력", isSecure: true)
 */

enum InputType {
    case number
    case text
}

struct CustomInputBox: View {
    var inputType: InputType = .text
    var placeholder: String
    
    // 커스텀 가능한 속성
    var cornerRadius: CGFloat = 12
    var height: CGFloat = 54
    var horizontalPadding: CGFloat = 4
    var showSheet: Bool = false
    var textColor: Color = .primary
    
    // 외부와 바인딩
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack {
            TextField(placeholder, text: $text)
                .disableAutocorrection(true) // QuickType 제거
                .textInputAutocapitalization(.never) // 자동 대문자 방지
                .foregroundColor(textColor)
                // .keyboardType(inputType == .number ? .numberPad : .default) // 숫자 키보드 설정
                .onChange(of: text) { oldValue, newValue in
                    if inputType == .number {
                        text = newValue.filter { $0.isNumber }
                    }
                }
                .padding(.horizontal, 12)
                .frame(height: height)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(borderColor(), lineWidth: borderWidth())
                        .background(RoundedRectangle(cornerRadius: cornerRadius).fill(Color(.systemBackground)))
                )
                .focused($isFocused)
                .disabled(showSheet)

            HStack {
                Spacer()
                // sheet 모드일 때 화살표 아이콘 표시
                if showSheet {
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                        .padding(.trailing)
                }
            }
        }
        .padding(.horizontal, horizontalPadding)
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
    
    private func borderColor() -> Color {
        if isFocused {
            return Color.purple300
        } else if !text.isEmpty {
            return Color.purple300
        } else {
            return Color.grey200
        }
    }
    
    private func borderWidth() -> CGFloat {
        if isFocused {
            return 3
        } else {
            return 1
        }
    }
}

struct CustomInputBox_Previews: PreviewProvider {
    @State static var idText: String = ""
    @State static var nameText: String = ""
    @State static var showSheet: Bool = true

    static var previews: some View {
        VStack(spacing: 16) {
            CustomInputBox(placeholder: "아이디 입력", text: $idText)
            CustomInputBox(placeholder: "sheet 생성", showSheet: showSheet, text: $nameText)
        }
        .padding()
    }
}
