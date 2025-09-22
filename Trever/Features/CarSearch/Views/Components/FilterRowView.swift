//
//  FilterRowView.swift
//  Trever
//
//  Created by OhChangEun on 9/22/25.
//

import SwiftUI

struct FilterRowView: View {
    let title: String
    let value: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                    .padding(.leading, 8)
                
                Spacer()
                
                Text(value)
                    .font(.system(size: 15))
                    .foregroundColor(Color.grey300.opacity(0.7))
                
                Image(systemName: "chevron.right")
                    .foregroundColor(Color.grey300.opacity(0.4))
                    .font(.system(size: 11))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 15)
            .padding(.top, 17)

        }
        .buttonStyle(PlainButtonStyle())
    }
}
