//
//  ApiResponse.swift
//  Trever
//
//  Created by 채상윤 on 9/19/25.
//

import Foundation

struct ApiResponse<T: Codable>: Codable {
    let status: Int
    let success: Bool
    let message: String
    let data: T
}
