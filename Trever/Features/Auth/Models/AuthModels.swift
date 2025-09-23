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
    let bidId: Int?
    let auctionId: Int?
    let bidderId: Int?
    let bidPrice: Int?
    let bidTime: String?
}

// MARK: - Purchase API Models
struct PurchaseResponse: Codable {
    let status: Int
    let success: Bool
    let message: String
    let data: PurchaseData?
}

struct PurchaseData: Codable {
    let id: Int
    let buyerId: Int
    let vehicleId: Int
    let buyerName: String
    let vehicleName: String
    let createdAt: String
}

// MARK: - Purchase Requests API Models
struct PurchaseRequestsResponse: Codable {
    let status: Int
    let success: Bool
    let message: String
    let data: [PurchaseRequestData]
}

struct PurchaseRequestData: Codable, Identifiable {
    let id: Int
    let buyerId: Int
    let vehicleId: Int
    let buyerName: String
    let vehicleName: String
    let createdAt: String
}

// MARK: - Transaction Complete API Models
struct TransactionCompleteResponse: Codable {
    let status: Int
    let success: Bool
    let message: String
    let data: TransactionCompleteData?
}

struct TransactionCompleteData: Codable {
    let transactionId: Int
    let vehicleId: Int
    let vehicleName: String
    let buyerName: String
    let sellerName: String
    let finalPrice: Int
    let status: String
    let createdAt: String
    let contractId: Int
    let contractPdfUrl: String
}

// MARK: - Contract API Models
struct ContractResponse: Codable {
    let status: Int
    let success: Bool
    let message: String
    let data: ContractData?
}

struct ContractData: Codable {
    let contractId: Int
    let transactionId: Int
    let buyerName: String
    let sellerName: String
    let status: String
    let signedAt: String
    let contractPdfUrl: String
}

// MARK: - Transaction History API Models
struct TransactionHistoryResponse: Codable {
    let status: Int
    let success: Bool
    let message: String
    let data: [TransactionHistoryData]
}

struct TransactionHistoryData: Codable, Identifiable {
    let transactionId: Int
    let vehicleId: Int
    let vehicleName: String
    let buyerName: String
    let sellerName: String
    let finalPrice: Int
    let status: String
    let createdAt: String
    let contractId: Int?
    let contractPdfUrl: String?
    
    var id: Int { transactionId }
}

// MARK: - Recent Views API Models
struct RecentViewsResponse: Codable {
    let status: Int
    let success: Bool
    let message: String
    let data: [RecentViewData]
}

struct RecentViewData: Codable, Identifiable {
    let id: Int
    let carName: String
    let carNumber: String?
    let manufacturer: String
    let model: String
    let yearValue: Int
    let mileage: Int
    let transmission: String
    let vehicleStatus: String?
    let fuelType: String
    let price: Int?
    let isAuction: String
    let auctionId: Int?
    let representativePhotoUrl: String?
    let favoriteCount: Int
    let createdAt: String
    let isFavorite: Bool?
    let vehicleTypeName: String?
    let mainOptions: [String]?
    let totalOptionsCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, carName, carNumber, manufacturer, model, mileage, transmission, vehicleStatus, fuelType, price, isAuction, auctionId, representativePhotoUrl, favoriteCount, createdAt, isFavorite, vehicleTypeName, mainOptions, totalOptionsCount
        case yearValue = "year_value"
    }
}

// MARK: - Favorites API Models
struct FavoritesResponse: Codable {
    let status: Int
    let success: Bool
    let message: String
    let data: [FavoriteData]
}

struct FavoriteData: Codable, Identifiable {
    let id: Int
    let carName: String
    let carNumber: String?
    let manufacturer: String
    let model: String
    let yearValue: Int
    let mileage: Int
    let transmission: String
    let vehicleStatus: String?
    let fuelType: String
    let price: Int?
    let isAuction: String
    let auctionId: Int?
    let representativePhotoUrl: String?
    let favoriteCount: Int
    let createdAt: String
    let isFavorite: Bool?
    let vehicleTypeName: String?
    let mainOptions: [String]?
    let totalOptionsCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, carName, carNumber, manufacturer, model, mileage, transmission, vehicleStatus, fuelType, price, isAuction, auctionId, representativePhotoUrl, favoriteCount, createdAt, isFavorite, vehicleTypeName, mainOptions, totalOptionsCount
        case yearValue = "year_value"
    }
}
