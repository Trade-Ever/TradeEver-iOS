import SwiftUI

struct MyPageView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("계정") {
                    HStack {
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: 36))
                            .foregroundStyle(.secondary)
                        VStack(alignment: .leading) {
                            Text("게스트")
                                .font(.headline)
                            Text("로그인하지 않음")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                Section("설정") {
                    Label("알림", systemImage: "bell")
                    Label("약관 및 개인정보", systemImage: "doc.text")
                }
            }
            .navigationTitle("마이페이지")
        }
    }
}

#Preview { MyPageView() }

