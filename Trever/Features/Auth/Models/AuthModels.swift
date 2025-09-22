//
//  AuthModels.swift
//  Trever
//
//  Created by 채상윤 on 9/22/25.
//

import Foundation

// MARK: - Google Login API Models
struct GoogleLoginRequest: Codable {
    let idToken: String
}

struct GoogleLoginResponse: Codable {
    let status: Int
    let success: Bool
    let message: String
    let data: GoogleLoginData?
}

struct GoogleLoginData: Codable {
    let accessToken: String
    let refreshToken: String
    let profileComplete: Bool
}

// MARK: - Profile Completion API Models
struct ProfileCompletionRequest: Codable {
    let name: String
    let phone: String
    let locationCity: String
    let birthDate: String
}

struct ProfileCompletionResponse: Codable {
    let status: Int
    let success: Bool
    let message: String
}
