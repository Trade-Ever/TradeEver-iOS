//
//  CustomMultilineInputBox.swift
//  Trever
//
//  Created by OhChangEun on 9/17/25.
//

import SwiftUI

struct CustomMultilineInputBox: View {
    var placeholder: String
    var cornerRadius: CGFloat = 12
    var minHeight: CGFloat = 80
    var horizontalPadding: CGFloat = 4
    var isEditable: Bool = true
    
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(Color.grey400)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }
            
            TextEditor(text: $text)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(minHeight: minHeight)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(borderColor(), lineWidth: borderWidth())
                        .background(RoundedRectangle(cornerRadius: cornerRadius).fill(Color.white))
                )
                .focused($isFocused)
                .disabled(!isEditable)
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

struct CustomMultilineInputBox_Previews: PreviewProvider {
    @State static var descText: String = ""
    
    static var previews: some View {
        CustomMultilineInputBox(placeholder: "내용 입력", text: $descText)
            .padding()
    }
}
