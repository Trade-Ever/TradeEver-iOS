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

struct CustomInputBox: View {
    var placeholder: String
    
    // 커스텀 가능한 속성
    var cornerRadius: CGFloat = 12
    var height: CGFloat = 54
    var horizontalPadding: CGFloat = 16
    
    @State private var text: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        Group {
            TextField(placeholder, text: $text)
                .padding(.horizontal, 12)
                .frame(height: height)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(borderColor(), lineWidth: borderWidth())
                        .background(RoundedRectangle(cornerRadius: cornerRadius).fill(Color.white))
                )
                .focused($isFocused)
        }
        .padding(.horizontal, horizontalPadding)
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
    
    private func borderColor() -> Color {
        if isFocused {
            return Color.purple400
        } else if !text.isEmpty {
            return Color.purple400
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

#Preview {
    VStack(spacing: 16) {
        CustomInputBox(placeholder: "아이디 입력")
        CustomInputBox(placeholder: "이름 입력")
    }
    .padding()
}
