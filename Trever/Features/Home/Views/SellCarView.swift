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
                ZStack(alignment: .bottom) {
                    Image("purple_car")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 210)   // 박스 높이
                        .clipped()
                        .cornerRadius(55) // 이미지 모서리 둥글게
                        .scaleEffect(1.2)
                        .offset(y: -10)
                    
                    // 차량 이미지 위 번호판 텍스트 버튼
                    ZStack {
                        // 배경
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white)
                            .frame(height: 50) // 버튼 높이
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.black, lineWidth: 3)
                            )
                        HStack(spacing: 3){
                            // 글자만 애니메이션
                            Text("차량 등록하기")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            // 글자만 애니메이션
                            Text("→")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .offset(x: offsetX) // 글자만 흔들리도록
                                .onAppear {
                                    withAnimation(
                                        Animation.easeInOut(duration: 0.7)
                                            .repeatForever(autoreverses: true)
                                    ) {
                                        offsetX = 2 // 오른쪽으로 이동 후 원위치 반복
                                    }
                                }
                        }
                        .offset(x: 5)
                    }
                    .frame(width: 210, height: 60)
                    .offset(y: 5)
                }
                Spacer()
            }
            .onTapGesture {
                showSellCarView = true
            }
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
