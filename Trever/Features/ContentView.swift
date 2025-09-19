//
//  ContentView.swift
//  Trever
//
//  Created by 채상윤 on 9/15/25.
//

import SwiftUI

enum MainTab: Hashable {
    case buy, sell, auction, mypage
}

struct ContentView: View {
    @State private var selection: MainTab = .buy
    @State private var selectedTab: Int = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ZStack {
                    switch selection {
                    case .sell: SellCarView()
                    case .auction: AuctionView()
                    case .mypage: MyPageView()
                    default: BuyCarView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                HStack {
                    CustomTabBar(selection: $selection)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
