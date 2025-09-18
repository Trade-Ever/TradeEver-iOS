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

    private let tabBarHeight: CGFloat = 66 // CustomTabBar 실제 높이
    @StateObject private var keyboard = KeyboardState()

    @State private var buyPath = NavigationPath()
    @State private var sellPath = NavigationPath()
    @State private var auctionPath = NavigationPath()
    @State private var myPagePath = NavigationPath()
    
    var body: some View {
        activeContent
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // Reserve space for the bar, independently of keyboard
            .safeAreaInset(edge: .bottom) {
                if showTabBar {
                    // Spacer only; prevents content being obscured
                    Color.clear.frame(height: tabBarHeight)
                }
            }
            // Render the bar pinned to bottom; it won't ride with keyboard
            .overlay(alignment: .bottom) {
                if showTabBar {
                    CustomTabBar(selection: $selection)
                        .ignoresSafeArea(.keyboard, edges: .bottom)
                }
            }
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

    private var showTabBar: Bool { !tabBarHidden && !keyboard.isVisible }
}

#Preview {
    ContentView()
}
