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

    var body: some View {
        TabView(selection: $selection) {
            BuyCarView().tag(MainTab.buy)
            SellCarView().tag(MainTab.sell)
            AuctionView().tag(MainTab.auction)
            MyPageView().tag(MainTab.mypage)
        }
        .toolbar(.hidden, for: .tabBar)
        // Add small breathing room under content so it doesn't feel clipped
        .safeAreaPadding(.bottom, 8)
        .safeAreaInset(edge: .bottom) {
            CustomTabBar(selection: $selection)
        }
    }
}

#Preview {
    ContentView()
}
