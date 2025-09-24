//
//  ManufacturerListView.swift
//  Trever
//
//  Created by OhChangEun on 9/19/25.
//

//
//  ManufacturerListView.swift
//  Trever
//
//  Created by OhChangEun on 9/19/25.
//

import SwiftUI

// 제조사 목록
struct CarManufacturerListView: View {
    
    // MARK: - 제조사 이름을 영어 에셋 이름으로 매핑
    private func getAssetName(for manufacturer: String) -> String {
        let mapping: [String: String] = [
            "현대": "hyundai",
            "기아": "kia",
            "제네시스": "genesis",
            "쉐보레": "chevrolet",
            "쌍용": "ssangyong",
            "르노": "renault",
            "BMW": "BMW",
            "벤츠": "mercedes",
            "아우디": "audi",
            "포르쉐": "porsche",
            "미니": "mini",
            "볼보": "volvo",
            "렉서스": "lexus",
            "인피니티": "infiniti",
            "아큐라": "acura",
            "토요타": "toyota",
            "혼다": "honda",
            "닛산": "nissan",
            "마쯔다": "mazda",
            "미쯔비시": "mitsubishi",
            "스바루": "subaru",
            "스즈키": "suzuki",
            "다이하쓰": "daihatsu",
            "폭스바겐": "volkswagen",
            "포드": "ford",
            "캐딜락": "cadillac",
            "링컨": "lincoln",
            "크라이슬러": "chrysler",
            "닷지": "dodge",
            "지프": "jeep",
            "람보르기니": "lamborghini",
            "페라리": "ferrari",
            "마세라티": "maserati",
            "벤틀리": "bentley",
            "롤스로이스": "rolls_royce",
            "부가티": "bugatti",
            "맥라렌": "mclaren",
            "테슬라": "tesla",
            "스마트": "smart",
            "푸조": "peugeot",
            "시트로엥": "citroen",
            "르노코리아": "renault_korea",
            "GMC": "GMC",
            "사이언": "scion",
            "새턴": "saturn",
            "북기은상": "bukgi",
            "중한자동차": "zhonghan",
            "허머": "hummer",
            "로터스": "lotus",
            "마이바흐": "maybach",
            "미쯔오까": "mitsubishi_fuso",
            "오펠": "opel",
            "피아트": "fiat",
            "재규어": "jaguar",
            "랜드로버": "land_rover"
        ]
        
        return mapping[manufacturer] ?? "default_car"
    }
    @ObservedObject var filter: CarFilterModel
    @StateObject private var viewModel = ManufacturerViewModel()

    @State private var navigateToNext = false    
    var includeYear: Bool = true                  // 연도까지 필터링할것인지
    let onComplete: ((CarFilterModel) -> Void)?   // 완료 콜백
    
    //    // 샘플 데이터
    //    let domesticCars: [(String, String, Int, Bool)] = [
    //        ("hyundai_logo", "현대", 44661, true),
    //        ("hyundai_logo", "제네시스", 11696, false),
    //        ("hyundai_logo", "기아", 11696, false),
    //        ("hyundai_logo", "쉐보레(GM 대우)", 11696, false),
    //        ("hyundai_logo", "르노코리아(삼성)", 11696, false)
    //    ]
    //
    //    let importedCars: [(String, String, Int, Bool)] = [
    //        ("hyundai_logo", "BMW", 11696, false),
    //        ("hyundai_logo", "벤츠", 11696, false),
    //        ("hyundai_logo", "아우디", 11696, false),
    //        ("hyundai_logo", "포르쉐", 11696, false),
    //        ("hyundai_logo", "미니", 11696, false)
    //    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .center, spacing: 12) {

                    if viewModel.isLoading {
                        ProgressView().padding()
                    } else {
                        Text("제조사")
                            .font(.title3)
                            .bold()
                            .padding(.top, 32)
                            .padding(.bottom, 28)
                        
                        CarFilterSection(
                            title: "국산차",
                            data: viewModel.domesticCars.map { (getAssetName(for: $0.manufacturer), $0.manufacturer, $0.count, false) },
                            showDivider: true,
                            onRowTap: { selectedManufacturer in
                                filter.category = "국산"
                                filter.manufacturer = selectedManufacturer
                                navigateToNext = true // 다음 단계(차명)로
                            }
                        )
                        
                        CarFilterSection(
                            title: "수입차",
                            data: viewModel.importedCars.map { (getAssetName(for: $0.manufacturer), $0.manufacturer, $0.count, false) },
                            onRowTap: { selectedManufacturer in
                                filter.category = "수입"
                                filter.manufacturer = selectedManufacturer
                                navigateToNext = true
                            }
                        )
                    }
                    Spacer(minLength: 40) // 하단 자리 확보
                }
                .task {
                    // 년도가 필요하면 > 차량 등록시 필요한 필터 > 숫자 등장 x
                    // 년도가 필요없으면 > 차량 검색시 필요한 필터 > 숫자 등장 o
                    await viewModel.fetchCarManufacturers(includeYear: includeYear)
                }
            }
            .navigationDestination(isPresented: $navigateToNext) {
                CarNameListView(filter: filter, includeYear: includeYear, onComplete: onComplete) // 완료 콜백 전달
            }
        }
    }
}
