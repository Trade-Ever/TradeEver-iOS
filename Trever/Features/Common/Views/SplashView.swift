
//
//  SplashView.swift
//  Trever
//
//  Created by Codex on 9/15/25.
//

import SwiftUI

struct SplashView: View {
    // Press state for tint effect
    @State private var isPressing: Bool = false

    private let brand = Color(red: 101/255, green: 40/255, blue: 247/255)

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Image("Trever")
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(24)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Trever 로딩 중")
    }
}

#Preview {
    SplashView()
}
