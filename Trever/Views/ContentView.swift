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
    @State private var tabBarHidden: Bool = false
    private let tabBarPadding: CGFloat = 0 // space for custom tab bar when visible

    @State private var buyPath = NavigationPath()
    @State private var sellPath = NavigationPath()
    @State private var auctionPath = NavigationPath()
    @State private var myPagePath = NavigationPath()

    var body: some View {
        ZStack(alignment: .bottom) {
            activeContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            CustomTabBar(selection: $selection)
                .opacity(tabBarHidden ? 0 : 1)
                .allowsHitTesting(!tabBarHidden)
        }
        .safeAreaPadding(.bottom, tabBarHidden ? 0 : tabBarPadding)
    }

    @ViewBuilder
    private var activeContent: some View {
        Group {
            switch selection {
            case .buy:
                NavigationStack(path: $buyPath) {
                    BuyCarView()
                        .tabBarHidden(false)
                }
            case .sell:
                NavigationStack(path: $sellPath) {
                    SellCarView()
                        .tabBarHidden(false)
                }
            case .auction:
                NavigationStack(path: $auctionPath) {
                    AuctionView()
                        .tabBarHidden(false)
                }
            case .mypage:
                NavigationStack(path: $myPagePath) {
                    MyPageView()
                        .tabBarHidden(false)
                }
            }
        }
        .onPreferenceChange(TabBarHiddenKey.self) { hidden in
            withAnimation(.easeInOut(duration: 0.2)) {
                tabBarHidden = hidden
            }
        }
    }
}

#Preview {
    ContentView()
}
