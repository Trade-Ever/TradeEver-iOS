//
//  BidListItem.swift
//  Trever
//
//  Created by 채상윤 on 9/17/25.
//

import SwiftUI

struct BidListItem: View {
    var bid: BidEntry
    
    var body: some View {
        HStack {
            Circle().fill(Color.grey100).frame(width: 36, height: 36)
                .overlay(Image(systemName: "person").foregroundStyle(.secondary))
            VStack(alignment: .leading, spacing: 2) {
                Text(bid.bidderName)
                    .font(.subheadline)
                Text(Formatters.dateTimeText(bid.placedAt))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(Formatters.priceText(won: bid.priceWon))
                .font(.headline).bold()
                .foregroundStyle(Color.priceGreen)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
        )
    }
}

#Preview {
    BidListItem(bid: BidEntry(
        bidderName: "홍길동",
        priceWon: 1500000,
        placedAt: Date()
    ))
}
