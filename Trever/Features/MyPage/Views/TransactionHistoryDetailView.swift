//
//  TransactionHistoryDetailView.swift
//  Trever
//
//  Created by 채상윤 on 9/23/25.
//

import SwiftUI

struct TransactionHistoryDetailView: View {
    @State private var selectedTab: TransactionTab = .sales
    
    init(initialTab: TransactionTab = .sales) {
        self._selectedTab = State(initialValue: initialTab)
    }
    
    enum TransactionTab: String, CaseIterable {
        case sales = "판매 내역"
        case purchases = "구매 내역"
        
        var title: String {
            return self.rawValue
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 탭 선택기
            tabSelector
            
            // 컨텐츠
            TabView(selection: $selectedTab) {
                TransactionHistoryView(isSalesHistory: true)
                    .tag(TransactionTab.sales)
                
                TransactionHistoryView(isSalesHistory: false)
                    .tag(TransactionTab.purchases)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .navigationTitle("거래 내역")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(TransactionTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 8) {
                        Text(tab.title)
                            .font(.headline)
                            .foregroundColor(selectedTab == tab ? .primary : .secondary)
                        
                        Rectangle()
                            .fill(selectedTab == tab ? Color.purple400 : Color.clear)
                            .frame(height: 2)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 16)
        .background(Color(.systemBackground))
    }
}
