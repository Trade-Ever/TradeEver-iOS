//
//  AFNetworkManager.swift
//  Trever
//
//  Created by OhChangEun on 9/18/25.
//
import Foundation
import Alamofire
import UIKit

final class AFNetworkManager {
    static let shared = AFNetworkManager()
    private init() {}
    
    func upload<T: Decodable>(
        to endpoint: APIEndpoint,
        request: Encodable,
        imagesData: [Data],
        responseType: T.Type
    ) async throws -> T {
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.upload(
                multipartFormData: { formData in
                    // 1. JSON 추가
                    if let jsonData = try? JSONEncoder().encode(request) {
                        //  JSON 문자열로 변환해서 로그 출력
                        if let jsonString = String(data: jsonData, encoding: .utf8) {
                            print("Request JSON: \(jsonString)")
                        }
                        formData.append(
                            jsonData,
                            withName: "request",
                            mimeType: "application/json"
                        )
                    }
                    
                    // 2. 이미지들 추가
                    for (index, imageData) in imagesData.enumerated() {
                        if let image = UIImage(data: imageData),
                           let compressedData = image.jpegData(compressionQuality: 0.5) {
                            formData.append(
                                compressedData,
                                withName: "photos",
                                fileName: "image\(index).jpg",
                                mimeType: "image/jpeg"
                            )
                        }
                    }
                },
                to: endpoint.url,
                method: .post
            )
            .validate(statusCode: 200..<300)
            .responseDecodable(of: responseType) { response in
                switch response.result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

