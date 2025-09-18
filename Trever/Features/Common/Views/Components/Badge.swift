//
//  Badge.swift
//  Trever
//
//  Created by 채상윤 on 9/17/25.
//

import SwiftUI

struct Badge: View {
    var text: String
    var color: Color = Color.likeRed
    
    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundStyle(.white)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(RoundedRectangle(cornerRadius: 8).fill(color))
    }
}

#Preview {
    Badge(text: "뱃지")
    Badge(text: "뱃지", color: Color.priceGreen)
}
