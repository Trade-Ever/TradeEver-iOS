//
//  ApiResponse.swift
//  Trever
//
//  Created by OhChangEun on 9/19/25.
//

struct ApiResponse<T: Decodable>: Decodable {
    let status: Int
    let success: Bool
    let message: String
    let data: T?
}
