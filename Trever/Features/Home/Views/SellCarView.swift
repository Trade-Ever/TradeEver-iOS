//
//  SellCarListView.swift
//  Trever
//
//  Created by OhChangEun on 9/18/25.
//

import SwiftUI

struct SellCarView: View {
    @State private var offsetX: CGFloat = 0
    @State private var animationCount = 0
    @State private var showSellCarView = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 상단에 이미지와 번호판                
                MySellCarView()
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .ignoresSafeArea(.all, edges: .top) // 상단 Safe Area 무시하여 이미지가 상단에 딱 붙게
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
