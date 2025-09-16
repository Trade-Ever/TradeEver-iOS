//
//  CustomPasswordInputBox.swift
//  Trever
//
//  Created by OhChangEun on 9/16/25.
//

import SwiftUI

struct PasswordInputBox: View {
    var placeholder: String
    
    // 커스텀 가능한 속성
    var cornerRadius: CGFloat = 12
    var height: CGFloat = 54
    var horizontalPadding: CGFloat = 16
    
    @State private var text: String = ""
    @FocusState private var isFocused: Bool
    @State private var isSecure: Bool = true // 기본은 비밀번호 모드
    
    var body: some View {
        HStack {
            if isSecure {
                SecureField(placeholder, text: $text)
                    .focused($isFocused)
            } else {
                TextField(placeholder, text: $text)
                    .focused($isFocused)
            }
            
            Button(action: {
                isSecure.toggle()
            }) {
                Image(systemName: isSecure ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(.gray)
            }
            .padding(.trailing, 4)
        }
        .padding(.horizontal, 12)
        .frame(height: height)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(borderColor(), lineWidth: borderWidth())
                .background(RoundedRectangle(cornerRadius: cornerRadius).fill(Color.white))
        )
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
        PasswordInputBox(placeholder: "비밀번호 입력")
    }
    .padding()
}
