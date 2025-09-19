//
//  NetworkError.swift
//  Trever
//
//  Created by OhChangEun on 9/18/25.
//

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingFailed
    case serverError(String) // 서버에서 내려주는 에러 메시지
    case unknown(Error)      // 기타 에러 Wrapping
}
