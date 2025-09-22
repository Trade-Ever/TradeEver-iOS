//
//  ProfileSetupView.swift
//  Trever
//
//  Created by 채상윤 on 9/22/25.
//

import SwiftUI

struct ProfileSetupView: View {
    @ObservedObject private var authViewModel = AuthViewModel.shared
    @State private var name = ""
    @State private var phone = ""
    @State private var birthDate = Date()
    @State private var locationCity = ""
    @State private var isSubmitting = false
    @State private var showingDatePicker = false
    @State private var tempBirthDate = Date()
    @FocusState private var focusedField: Field?
    
    private let brand = Color(red: 101/255, green: 40/255, blue: 247/255)
    
    enum Field: Hashable {
        case name, phone, locationCity
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // 스크롤 가능한 입력 폼
                    ScrollView {
                        VStack(spacing: 0) {
                            // 상단 여백
                            Spacer()
                                .frame(height: 40)
                            
                            // 입력 폼
                            VStack(spacing: 20) {
                                // 이름 입력
                                CustomInputBox(
                                    placeholder: "이름을 입력하세요",
                                    text: $name
                                )
                                .focused($focusedField, equals: .name)
                                .onSubmit {
                                    focusedField = .phone
                                }
                                
                                // 전화번호 입력
                                CustomInputBox(
                                    inputType: .number,
                                    placeholder: "전화번호를 입력하세요. (010-0000-0000)",
                                    text: $phone
                                )
                                .focused($focusedField, equals: .phone)
                                .onSubmit {
                                    focusedField = .locationCity
                                }
                                
                                // 생년월일 입력
                                CustomInputBox(
                                    placeholder: dateFormatter.string(from: birthDate),
                                    showSheet: true,
                                    textColor: .black, text: .constant("")
                                )
                                .onTapGesture {
                                    tempBirthDate = birthDate
                                    showingDatePicker = true
                                }
                                
                                // 지역 입력
                                CustomInputBox(
                                    placeholder: "지역을 입력하세요",
                                    text: $locationCity
                                )
                                .focused($focusedField, equals: .locationCity)
                                .onSubmit {
                                    focusedField = nil
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            // 하단 여백 (키보드 대응)
                            Spacer()
                                .frame(height: focusedField != nil ? 150 : 100)
                        }
                        .frame(minHeight: geometry.size.height - 100) // 최소 높이 설정
                    }
                    
                    // 하단 고정 버튼
                    VStack {
                        Button(action: {
                            submitProfile()
                        }) {
                            Text("입력 완료")
                                .font(.headline)
                                .foregroundColor(Color.primaryText)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(isFormValid ? brand : Color.grey100)
                                .cornerRadius(8)
                                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                        .disabled(!isFormValid || isSubmitting)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                    .background(Color(.systemBackground))
                }
            }
            .navigationTitle("추가정보 입력")
        }
        .sheet(isPresented: $showingDatePicker) {
            VStack(spacing: 0) {
                // DatePicker
                DatePicker("생년월일", selection: $tempBirthDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding()
                
                Spacer()
                
                // 선택 버튼
                Button(action: {
                    birthDate = tempBirthDate
                    showingDatePicker = false
                }) {
                    Text("선택")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(brand)
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .presentationDetents([.medium])
        }
        .overlay(
            // 로딩 인디케이터
            Group {
                if isSubmitting {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        
                        Text("정보 저장 중...")
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
        .onAppear {
            // 첫 번째 필드에 포커스
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                focusedField = .name
            }
        }
        .onTapGesture {
            // 화면 터치 시 키보드 숨김
            focusedField = nil
        }
    }
    
    // 폼 유효성 검사
    private var isFormValid: Bool {
        return !name.isEmpty && 
               !phone.isEmpty && 
               !locationCity.isEmpty
    }
    
    // 날짜 포맷터
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    
    // 프로필 정보 제출
    private func submitProfile() {
        isSubmitting = true
        
        Task {
            let success = await authViewModel.completeProfile(
                name: name,
                phone: phone,
                birthDate: dateFormatter.string(from: birthDate),
                locationCity: locationCity
            )
            
            await MainActor.run {
                isSubmitting = false
                if success {
                    print("프로필 정보 제출 성공 - 메인 화면으로 이동")
                }
            }
        }
    }
}

#Preview {
    ProfileSetupView()
}
