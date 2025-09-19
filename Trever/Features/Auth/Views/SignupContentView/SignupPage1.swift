//
//  SignupPage1.swift
//  Trever
//
//  Created by OhChangEun on 9/19/25.
//

import SwiftUI

struct SignupPage1: View {
    @Binding var email: String
    @Binding var password: String
    @Binding var checkedPassword: String
    @FocusState var focusedField: SignupView.Field?
    
    @State private var step: Int = 0 // 내부 step 관리
    
    var body: some View {
        VStack(spacing: 12) {
            
            // 상단 여백 추가
            Spacer().frame(height: 40)

            // Step 0: 이메일
            if step >= 0 {
                InputSection(title: "이메일") {
                    CustomInputBox(placeholder: "example@gmail.com", text: $email)
                        .focused($focusedField, equals: .email)
                        .onSubmit {
                            if !email.isEmpty {
                                withAnimation(.easeInOut) { step = max(step, 1) }
                                focusedField = .password
                            }
                        }
                }
            }
            
            // Step 1: 비밀번호
            if step >= 1 {
                InputSection(title: "비밀번호") {
                    CustomInputBox(placeholder: "비밀번호", text: $password)
                        .focused($focusedField, equals: .password)
                        .onSubmit {
                            if !password.isEmpty {
                                withAnimation(.easeInOut) { step = max(step, 2) }
                                focusedField = .checkedPassword
                            }
                        }
                }
            }
            
            // Step 2: 비밀번호 확인
            if step >= 2 {
                InputSection(title: "비밀번호 확인") {
                    CustomInputBox(placeholder: "비밀번호 확인", text: $checkedPassword)
                        .focused($focusedField, equals: .checkedPassword)
                        .onSubmit {
                            if !checkedPassword.isEmpty {
                                withAnimation(.easeInOut) { step = max(step, 3) }
                                focusedField = nil // 마지막 Step 완료 시 포커스 해제
                            }
                        }
                }
            }
        }
        .onAppear {
            focusedField = .email
        }
    }
}

