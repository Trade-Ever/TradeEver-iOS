//
//  CustomSelectableButton.swift
//  Trever
//
//  Created by OhChangEun on 9/16/25.
//

import SwiftUI

struct SelectableButton: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.purple300 : Color(UIColor.systemBackground))
                .foregroundColor(isSelected ? .white : .grey200)
                .cornerRadius(50)
                .overlay(
                    RoundedRectangle(cornerRadius: 50)
                        .stroke(isSelected ? Color.clear : Color.grey200, lineWidth: 1.5)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
struct SelectableButton_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var selected: Bool = false
        
        var body: some View {
            SelectableButton(
                title: "SUV",
                isSelected: selected,
                action: { selected.toggle() }
            )
        }
    }
    
    static var previews: some View {
        PreviewWrapper()
    }
}
