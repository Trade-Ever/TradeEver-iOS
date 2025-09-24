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
    @ObservedObject private var authViewModel = AuthViewModel.shared
    @State private var selection: MainTab = .buy
    @State private var selectedTab: Int = 0
    
    var body: some View {
        Group {
            if authViewModel.isSignedIn {
                // 로그인 후에만 프로필 완성 여부 확인
                if authViewModel.isNewLogin && !authViewModel.profileComplete {
                    // 새로 로그인했고 프로필 미완성 - 추가 정보 입력 화면
                    ProfileSetupView()
                } else {
                    // 자동 로그인이거나 프로필 완성 - 메인 화면
                    mainContentView
                }
            } else {
                // 토큰이 없으면 로그인 화면
                LoginView()
            }
        }
        .onAppear {
            print("ContentView 나타남")
            print("   - 로그인 상태: \(authViewModel.isSignedIn)")
            print("   - 프로필 완성: \(authViewModel.profileComplete)")
            print("   - 새로 로그인: \(authViewModel.isNewLogin)")
            
            if authViewModel.isSignedIn {
                if authViewModel.isNewLogin && !authViewModel.profileComplete {
                    print("   → 새로 로그인 + 프로필 미완성 - 추가 정보 입력 화면")
                } else {
                    print("   → 자동 로그인이거나 프로필 완성 - 메인 화면")
                }
            } else {
                print("   → 토큰 없음 - 로그인 화면으로 이동")
            }
        }
    }
    
    private var mainContentView: some View {
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
                .background(Color(.systemGroupedBackground))
                
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
