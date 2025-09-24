//
//  TopBarBanner.swift
//  Trever
//
//  Created by OhChangEun on 9/24/25.
//

import SwiftUI

struct TopBannerView: View {
    @State private var offsetX: CGFloat = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            // 상단 이미지
            Image("purple_car")
                .resizable()
                .scaledToFill()
                .frame(height: 210)
                .clipped()
                .cornerRadius(55)
                .scaleEffect(1.15)
                .offset(y: -20)

            // 차량 등록 버튼
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
                    .frame(height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black, lineWidth: 3)
                    )

                HStack(spacing: 3) {
                    Text("차량 등록하기")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.leading, 2)

                    Text("→")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .offset(x: offsetX)
                        .onAppear {
                            withAnimation(
                                Animation.easeInOut(duration: 0.7)
                                    .repeatForever(autoreverses: true)
                            ) {
                                offsetX = 2
                            }
                        }
                }
            }
            .frame(width: 210, height: 50)
            .offset(y: -15) // 버튼을 이미지 중앙보다 살짝 위로 올림
        }
    }
}

struct TopBannerView_Previews: PreviewProvider {
    static var previews: some View {
        TopBannerView()
    }
}
