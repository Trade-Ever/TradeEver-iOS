//
//  UserInputSection.swift
//  Trever
//
//  Created by OhChangEun on 9/16/25.
//

import SwiftUI

/// 사용자 입력용 공통 섹션 컴포넌트
/// - 큰 제목(Label)을 표시하고
/// - 그 아래에 InputBox, Button, Picker 등 다양한 뷰를 자유롭게 배치할 수 있음
struct InputSection<Content: View>: View {
    /// 제목 텍스트
    var title: String
    var subTitle: String?
    
    /// 뷰 빌더: 섹션 안에 원하는 뷰를 삽입할 수 있도록 지원
    let content: () -> Content
    
    /// 초기화 메서드
    /// - Parameters:
    ///   - title: 섹션 상단에 표시할 제목
    ///   - subTitle: 제목 우측에 조건(km, 원 등)
    ///   - content: 섹션 본문에 들어갈 커스텀 뷰
    init(title: String, subTitle: String? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
        self.subTitle = subTitle
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 제목 - 부제(조건)
            HStack (spacing: 4) {
                Text(title)
                    .font(.system(size: 23))
                    .fontWeight(.black)
                    .foregroundStyle(Color.grey400)
                    .padding(.leading, 24)
                if let subTitle = subTitle {
                    Text(subTitle)
                        .font(.system(size: 18))
                        .bold()
                        .foregroundStyle(Color.grey400.opacity(0.4))
                        .padding(.top, 2)
                }
                Spacer()
            }
            
            // 커스텀 콘텐츠 (InputBox, Button, Toggle 등)
            content()
                .padding(.horizontal, 16) // 좌우 여백

        }
        .padding(.vertical, 8)   // 상하 여백
    }
}

#Preview {
    InputSection(title: "차량 번호", subTitle: "(km)") {
        TextField("예: 12가 3456", text: .constant(""))
            .textFieldStyle(RoundedBorderTextFieldStyle())
    }
}
