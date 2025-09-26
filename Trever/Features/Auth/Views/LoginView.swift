//
//  LoginView.swift
//  Trever
//
//  Created by OhChangEun on 9/18/25.
//

import SwiftUI
import GoogleSignIn
 
struct LoginView: View {
    @ObservedObject private var authViewModel = AuthViewModel.shared
    @State private var showingSignup = false
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Image("Trever")
                    .resizable()
//                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                
                // Google 로그인 버튼
                Button(action: {
                    Task {
                        await authViewModel.signInWithGoogle()
                    }
                }) {
                    HStack {
                        Image("google_logo")
                            .resizable()
                            .frame(width: 20, height: 20)
                        
                        Text("Google 계정으로 계속하기")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.separator), lineWidth: 1)
                    )
                    .cornerRadius(12)
                    .shadow(color: Color.primary.opacity(0.1), radius: 4, x: 0, y: 2)
                }
                .disabled(authViewModel.isLoading)
                .padding(.horizontal, 32)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(24)
        }
        .overlay(
            // 로딩 인디케이터
            Group {
                if authViewModel.isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()

                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))

                        Text("로그인 중...")
                            .foregroundColor(.white)
                            .padding(.top, 16)
                    }
                }
            }
        )
        .alert("오류", isPresented: .constant(authViewModel.errorMessage != nil)) {
            Button("확인") {
                authViewModel.errorMessage = nil
            }
        } message: {
            Text(authViewModel.errorMessage ?? "")
        }
        .onChange(of: authViewModel.isSignedIn) { _, newValue in
            print("로그인 상태 변경: \(newValue)")
            if newValue {
                print("로그인 성공")
            } else {
                print("로그아웃됨")
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Trever 로그인")
    }
}

#Preview {
    LoginView()
}
