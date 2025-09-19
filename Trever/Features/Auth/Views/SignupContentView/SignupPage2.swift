//
//  SignupPage1.swift
//  Trever
//
//  Created by OhChangEun on 9/19/25.
//

import SwiftUI

struct SignupPage2: View {
    @Binding var name: String
    @Binding var phone: String
    @Binding var profileImageUrl: String
    @Binding var locationCity: String
    @Binding var birthDate: Date
    @FocusState var focusedField: SignupView.Field?
    
    @State private var step: Int = 0 // 내부 step 관리
    
    var body: some View {
        VStack(spacing: 12) {
            
            // 상단 여백 추가
            Spacer().frame(height: 40)
            
            // Step 0: 프로필 이미지
            InputSection(title: "프로필 이미지") {
                CustomInputBox(placeholder: "프로필 이미지 URL", text: $profileImageUrl)
                    .focused($focusedField, equals: .profileImageUrl)
                    .onSubmit {
                        if !profileImageUrl.isEmpty {
                            withAnimation(.easeInOut) { step = max(step, 1) }
                            focusedField = .name
                        }
                    }
            }
            
            // Step 1: 이름
            if step >= 1 {
                InputSection(title: "이름") {
                    CustomInputBox(placeholder: "홍길동", text: $name)
                        .focused($focusedField, equals: .name)
                        .onSubmit {
                            if !name.isEmpty {
                                withAnimation(.easeInOut) { step = max(step, 2) }
                                focusedField = .phone
                            }
                        }
                }
            }

            // Step 2: 전화번호
            if step >= 2 {
                InputSection(title: "전화번호") {
                    CustomInputBox(inputType: .number, placeholder: "01012345678", text: $phone)
                        .focused($focusedField, equals: .phone)
                        .onSubmit {
                            if !phone.isEmpty {
                                withAnimation(.easeInOut) { step = max(step, 3) }
                                focusedField = .phone
                            }
                        }
                }
            }
            
            // Step 3: 거주 도시
            if step >= 3 {
                InputSection(title: "거주 도시") {
                    CustomInputBox(placeholder: "거주 도시", text: $locationCity)
                        .focused($focusedField, equals: .locationCity)
                        .onSubmit {
                            if !locationCity.isEmpty {
                                withAnimation(.easeInOut) { step = max(step, 4) }
                                focusedField = nil
                            }
                        }
                }
            }
            
            // Step 4: 생년월일
            if step >= 4 {
                InputSection(title: "생년월일") {
                    DatePicker("생년월일", selection: $birthDate, displayedComponents: .date)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            Spacer() // 하단 여백 확보
        }
        .onAppear {
            focusedField = .profileImageUrl
        }
    }
}

