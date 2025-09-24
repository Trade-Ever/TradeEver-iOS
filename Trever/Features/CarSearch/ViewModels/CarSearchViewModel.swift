    //
    //  CarSearchViewModel.swift
    //  Trever
    //
    //  Created by OhChangEun on 9/22/25.
    //

    import Foundation
    import Combine
    import Alamofire

    @MainActor
    class CarSearchViewModel: ObservableObject {
        @Published var recentSearches: [String] = []
        @Published var searchText: String = ""
        
        @Published var vehicles: [Vehicle] = []
        @Published var totalCount: Int = 0
        @Published var currentPage: Int = 1   // 클라이언트는 1-based
        @Published var totalPages: Int = 0
        @Published var isSearching: Bool = false
        @Published var hasMoreData: Bool = true
        
        @Published var errorMessage: String? = nil
        
        private let pageSize = 20

        // MARK: - 필터 조건으로 검색 API 호출
        func fetchFilteredCars(with carSearch: CarSearchModel, isLoadMore: Bool = false) async {
            if !isLoadMore {
                currentPage = 1
                vehicles = []
                totalCount = 0
                totalPages = 0
                hasMoreData = true
            }
            
            // 검색 시작 시 바로 최근 검색 기록 업데이트
            if let keyword = carSearch.keyword, !keyword.trimmingCharacters(in: .whitespaces).isEmpty {
                await fetchRecentSearches() // 최신 기록 불러오기
            }
            
            if isSearching || (!isLoadMore && !hasMoreData && currentPage > 1) {
                return
            }
            
            isSearching = true
            errorMessage = nil
            
            do {
                // 서버는 0-based page, 클라이언트는 1-based → 변환
                var requestModel = transform(with: carSearch)
                requestModel.page = max(currentPage - 1, 0)
                requestModel.size = pageSize
                
                let parameters = requestModel.toDictionary()
                
                // ✅ 요청 파라미터 로그
                if let jsonData = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    print("📤 [차량검색 요청] page=\(requestModel.page), size=\(pageSize)")
                    print(jsonString)
                }
                
                let response: ApiResponse<CarSearchResponse> = try await NetworkManager.shared.request(
                    to: .vehicleSearch,
                    method: .post,
                    parameters: parameters,
                    encoding: JSONEncoding.default,
                    responseType: ApiResponse<CarSearchResponse>.self
                )
      
                // ✅ 상세한 요청 로그
                print("📤 [차량검색 요청 상세 정보]")
                print("   - 원본 carSearch 데이터:")
                print("     * keyword: \(carSearch.keyword ?? "nil")")
                print("     * manufacturer: \(carSearch.manufacturer ?? "nil")")
                print("     * carName: \(carSearch.carName ?? "nil")")
                print("     * carModel: \(carSearch.carModel ?? "nil")")
                print("     * yearStart: \(carSearch.yearStart?.description ?? "nil")")
                print("     * yearEnd: \(carSearch.yearEnd?.description ?? "nil")")
                print("     * mileageStart: \(carSearch.mileageStart?.description ?? "nil")")
                print("     * mileageEnd: \(carSearch.mileageEnd?.description ?? "nil")")
                print("     * priceStart: \(carSearch.priceStart?.description ?? "nil")")
                print("     * priceEnd: \(carSearch.priceEnd?.description ?? "nil")")
                print("     * vehicleType: \(carSearch.vehicleType ?? "nil")")

                print("   - 클라이언트 상태:")
                print("     * currentPage (1-based): \(currentPage)")
                print("     * pageSize: \(pageSize)")
                print("     * isLoadMore: \(isLoadMore)")

                print("   - 변환된 requestModel:")
                print("     * page (0-based): \(requestModel.page)")
                print("     * size: \(requestModel.size)")

                // JSON 요청 내용 출력
                if let jsonData = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    print("📋 [실제 서버 요청 JSON]")
                    print(jsonString)
                } else {
                    print("⚠️ JSON 직렬화 실패")
                    print("📋 [파라미터 딕셔너리] \(parameters)")
                }
                
                
                
                
                if response.success, let searchData = response.data {
                    // ✅ 원본 서버 응답 데이터 확인
                    print("🔍 [서버 응답 상세 분석]")
                    print("   - searchData.totalCount: \(searchData.totalCount)")
                    print("   - searchData.pageNumber: \(searchData.pageNumber)")
                    print("   - searchData.pageSize: \(searchData.pageSize)")
                    print("   - searchData.vehicles.count: \(searchData.vehicles.count)")
                    print("   - 클라이언트 currentPage (요청 전): \(currentPage)")
                    print("   - isLoadMore: \(isLoadMore)")
                    
                    totalCount = searchData.totalCount
                    let serverPage = searchData.pageNumber
                    let serverPageSize = searchData.pageSize > 0 ? searchData.pageSize : pageSize
                    totalPages = serverPageSize > 0 ? Int(ceil(Double(totalCount) / Double(serverPageSize))) : 1
                    hasMoreData = (serverPage + 1) < totalPages
                    
                    print("   - 계산된 totalPages: \(totalPages)")
                    print("   - 계산된 hasMoreData: \(hasMoreData)")
                    
                    // ✅ vehicles 배열 업데이트 전후 상태 확인
                    print("   - vehicles.count (업데이트 전): \(vehicles.count)")
                    
                    if isLoadMore {
                        vehicles.append(contentsOf: searchData.vehicles)
                        print("   - 더보기 모드로 \(searchData.vehicles.count)개 추가")
                    } else {
                        vehicles = searchData.vehicles
                        print("   - 새 검색으로 \(searchData.vehicles.count)개 설정")
                    }
                    
                    print("   - vehicles.count (업데이트 후): \(vehicles.count)")
                    
                    // 클라이언트 currentPage를 1-based로 맞춤
                    currentPage = serverPage + 1
                    
                    print("✅ 차량 검색 성공")
                    print("   - 현재 페이지: \(currentPage)")
                    print("   - 전체 페이지: \(totalPages)")
                    print("   - 전체 개수: \(totalCount)")
                    print("   - 현재 결과 개수: \(vehicles.count)")
                    
                    // ✅ 수정된 차량 목록 출력
                    print("📋 [검색된 차량 목록]")
                    if searchData.vehicles.isEmpty {
                        print("   ⚠️ searchData.vehicles가 비어있습니다!")
                    } else {
                        for (index, vehicle) in searchData.vehicles.enumerated() {
                            let vehicleName = [
                                vehicle.manufacturer,
                                vehicle.model
                            ].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: " ")
                            
                            let displayName = vehicleName.isEmpty ? "차량명 없음" : vehicleName
                            let price = vehicle.price.map { "\(Formatters.priceToEokFormat(Double($0)))" } ?? "가격정보없음"
                            
                            print("   \(index + 1). \(displayName) - \(price)")
                        }
                    }
                    
                    await fetchRecentSearches()
                } else {
                    errorMessage = response.message
                    print("❌ 차량 검색 실패: \(response.message)")
                }
                
            } catch {
                errorMessage = "네트워크 오류가 발생했습니다: \(error.localizedDescription)"
                print("❌ 차량 검색 네트워크 오류: \(error)")
            }
            
            isSearching = false
        }

        // MARK: - 최근 검색 기록 조회
        func fetchRecentSearches() async {
            print("📤 [최근검색 요청]")
            do {
                let response: ApiResponse<[String]> = try await NetworkManager.shared.request(
                    to: .recentSearch,
                    responseType: ApiResponse<[String]>.self
                )
                
                print("📥 [최근검색 응답] success=\(response.success), data=\(response.data ?? [])")
                
                if response.success, let searches = response.data {
                    recentSearches = Array(searches.prefix(5))
                } else {
                    errorMessage = response.message
                }
            } catch {
                errorMessage = error.localizedDescription
                print("❌ 최근검색 네트워크 오류: \(error)")
            }
        }

        // MARK: - 최근 검색 기록 삭제
        func removeRecentSearch(_ keyword: String) async {
            print("📤 [최근검색 삭제 요청] keyword=\(keyword)")
            do {
                let response: ApiResponse<String> = try await NetworkManager.shared.request(
                    to: .deleteRecentSearch(keyword: keyword),
                    method: .delete,
                    responseType: ApiResponse<String>.self
                )
                
                print("📥 [최근검색 삭제 응답] success=\(response.success), message=\(response.message)")
                
                if response.success {
                    recentSearches.removeAll { $0 == keyword }
                    print("✅ '\(keyword)' 삭제 완료")
                } else {
                    errorMessage = response.message
                }
            } catch {
                errorMessage = error.localizedDescription
                print("❌ 최근검색 삭제 네트워크 오류: \(error)")
            }
        }

        // MARK: - 변환: CarSearch -> CarSearchRequest
        func transform(with carSearch: CarSearchModel) -> CarSearchRequest {
            return CarSearchRequest(
                keyword: carSearch.keyword,
                manufacturer: carSearch.manufacturer,
                carName: carSearch.carName,
                carModel: carSearch.carModel,
                yearStart: carSearch.yearStart,
                yearEnd: carSearch.yearEnd,
                mileageStart: carSearch.mileageStart,
                mileageEnd: carSearch.mileageEnd,
                priceStart: carSearch.priceStart,
                priceEnd: carSearch.priceEnd,
                vehicleType: carSearch.vehicleType,
                page: 0,   // 서버는 0-based
                size: pageSize
            )
        }
    }

    extension CarSearchRequest {
        func toDictionary() -> [String: Any] {
            var dict: [String: Any] = [:]
            
            if let keyword = keyword { dict["keyword"] = keyword }
            if let manufacturer = manufacturer { dict["manufacturer"] = manufacturer }
            if let carName = carName { dict["carName"] = carName }
            if let carModel = carModel { dict["carModel"] = carModel }
            if let yearStart = yearStart { dict["yearStart"] = yearStart }
            if let yearEnd = yearEnd { dict["yearEnd"] = yearEnd }
            if let mileageStart = mileageStart { dict["mileageStart"] = mileageStart }
            if let mileageEnd = mileageEnd { dict["mileageEnd"] = mileageEnd }
            if let priceStart = priceStart { dict["priceStart"] = priceStart }
            if let priceEnd = priceEnd { dict["priceEnd"] = priceEnd }
            if let vehicleType = vehicleType { dict["vehicleType"] = vehicleType }
            
            dict["page"] = page
            dict["size"] = size
            
            return dict
        }
    }
