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

// MARK: - User Profile API Models
struct UserProfileResponse: Codable {
    let status: Int
    let success: Bool
    let message: String
    let data: UserProfileData?
}

struct UserProfileData: Codable {
    let userId: Int
    let email: String
    let name: String
    let phone: String
    let profileImageUrl: String?
    let birthDate: String
    let locationCity: String
    let balance: Int
}

// MARK: - Token Reissue API Models
struct TokenReissueRequest: Codable {
    let refreshToken: String
}

struct TokenReissueResponse: Codable {
    let status: Int
    let success: Bool
    let message: String
    let data: TokenReissueData?
}

struct TokenReissueData: Codable {
    let accessToken: String
    let refreshToken: String
    let profileComplete: Bool
}

// MARK: - Wallet API Models
struct WalletResponse: Codable {
    let status: Int
    let success: Bool
    let message: String
    let data: Int
}

// MARK: - Profile Update API Models
struct ProfileUpdateRequest: Codable {
    let name: String
    let phone: String
    let locationCity: String
    let birthDate: String
}

struct ProfileUpdateResponse: Codable {
    let status: Int
    let success: Bool
    let message: String
}
