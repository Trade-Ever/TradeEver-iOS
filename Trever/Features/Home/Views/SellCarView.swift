//
//  SellCarListView.swift
//  Trever
//
//  Created by OhChangEun on 9/18/25.
//

import SwiftUI

struct SellCarView: View {
    @State private var showSellCarView = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("메인 페이지")
                    .font(.largeTitle)
                
                Button("차량 판매 등록 시작") {
                    showSellCarView = true
                }
            }
            .navigationDestination(isPresented: $showSellCarView) {
                SellCarRegisterView()
            }
        }
    }
}

struct SellCarMainView_Previews: PreviewProvider {
    static var previews: some View {
        SellCarView()
    }
}
