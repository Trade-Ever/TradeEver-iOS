//
//  ActionButtonsView.swift
//  Trever
//
//  Created by OhChangEun on 9/22/25.
//

import SwiftUI

struct ActionButtonsView: View {
    let onReset: () -> Void
    let onSearch: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onReset) {
                Text("초기화")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue, lineWidth: 1)
                    )
            }
            
            Button(action: onSearch) {
                Text("매물보기")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 34) // Safe area bottom padding
    }
}
