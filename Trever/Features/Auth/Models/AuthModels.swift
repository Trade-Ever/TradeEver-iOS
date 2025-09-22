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
    let profileComplete: Bool?
    
    // 프로필 완성 상태를 판단하는 computed property
    var isProfileComplete: Bool {
        // name, phone, birthDate, locationCity가 모두 비어있지 않으면 프로필 완성으로 간주
        return !name.isEmpty && !phone.isEmpty && !birthDate.isEmpty && !locationCity.isEmpty
    }
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

// MARK: - Auction Bid API Models
struct BidRequest: Codable {
    let auctionId: Int
    let bidPrice: Int
}

struct BidResponse: Codable {
    let status: Int
    let success: Bool
    let message: String
    let data: BidData?
}

struct BidData: Codable {
    let bidId: Int
    let auctionId: Int
    let bidderId: Int
    let bidPrice: Int
    let bidTime: String
}
