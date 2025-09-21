import SwiftUI

struct MyPageView: View {
    private let brand = Color.purple400

    var body: some View {
        List {
            HStack {
                Image("Trever")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 50)
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 0, trailing: 16))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)

            Section { profileCard.listRowSeparator(.hidden) }

            Section { accountPill.listRowSeparator(.hidden) }

            Section("나의 활동") {
                NavigationLink("최근 본 차") { MyActivityDetailView(initialTab: .recent) }
                NavigationLink("찜한 차") { MyActivityDetailView(initialTab: .liked) }
            }
            
            Section("거래 내역") {
                NavigationLink("판매 내역") { TransactionHistoryDetailView(initialTab: .sales) }
                NavigationLink("구매 내역") { TransactionHistoryDetailView(initialTab: .purchases) }
            }

            Section("고객지원") {
                NavigationLink("약관 및 정책") { TermsView() }
                NavigationLink("개인정보 처리방침") { PrivacyPolicyView() }
                Button(role: .destructive) { /* TODO: logout */ } label: { Text("로그아웃") }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var profileCard: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
                Text("닉네임").font(.title3).bold()
                Text("nick@email.com").foregroundStyle(.secondary)
            }
            Spacer()
            Circle()
                .fill(Color.grey100)
                .frame(width: 48, height: 48)
                .overlay(Image(systemName: "person").foregroundStyle(.secondary))
        }
        .padding(16)
    }

    private var accountPill: some View {
        HStack(spacing: 12) {
            Text("내 계좌").foregroundStyle(.white).bold()
            Spacer()
            Text("10,000원").foregroundStyle(.white)
            Capsule()
                .fill(Color.white.opacity(0.2))
                .frame(width: 1, height: 16)
            Button("충전") {}
                .foregroundStyle(.white)
            Text("|").foregroundStyle(.white.opacity(0.6))
            Button("출금") {}
                .foregroundStyle(.white)
        }
        .font(.subheadline)
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .listRowInsets(EdgeInsets())
        .background(Color.purple400)
    }
}

#Preview { MyPageView() }

private struct MyPagePlaceholder: View {
    let title: String
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("\(title) 화면 준비 중")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}
