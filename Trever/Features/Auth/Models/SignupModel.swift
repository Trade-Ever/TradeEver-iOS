//
//  SignupModel.swift
//  Trever
//
//  Created by OhChangEun on 9/18/25.
//

import Foundation

final class SignupModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var checkedPassword: String = ""
    @Published var profileImageUrl: String = ""
    @Published var name: String = ""
    @Published var phone: String = ""
    @Published var birthDate: Date = Date()
    @Published var locationCity: String = ""
    
    func isStepCompleted(currentStep: Int) -> Bool {
        switch currentStep {
        case 0:
            // Step 0: 이메일 + 비밀번호 + 비밀번호 확인 모두 입력되어야 함
            return !email.isEmpty && !password.isEmpty && !checkedPassword.isEmpty

        case 1:
            // Step 1: 이름 + 전화번호 모두 입력되어야 함
            return !profileImageUrl.isEmpty && !name.isEmpty && !phone.isEmpty && !locationCity.isEmpty

        default:
            return true
        }
    }
}
