import SwiftUI

struct MyPageView: View {
    @ObservedObject private var authViewModel = AuthViewModel.shared
    @State private var showingLogoutAlert = false
    @State private var showingLogoutSuccessAlert = false
    @State private var isLoggingOut = false
    @State private var userProfile: UserProfileData?
    @State private var isLoadingProfile = false
    @State private var walletBalance: Int?
    @State private var isLoadingWallet = false
    @State private var showingProfileEdit = false
    @State private var isUpdatingProfile = false
    @State private var showingDepositView = false
    @State private var showingWithdrawView = false
    
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
                Button(role: .destructive) {
                    showingLogoutAlert = true
                } label: { 
                    HStack {
                        Text("로그아웃")
                        if isLoggingOut {
                            Spacer()
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                }
                .disabled(isLoggingOut)
            }
        }
        .listStyle(.insetGrouped)
        .alert("로그아웃", isPresented: $showingLogoutAlert) {
            Button("취소", role: .cancel) { }
            Button("로그아웃", role: .destructive) {
                performLogout()
            }
        } message: {
            Text("로그아웃 하시겠습니까?")
        }
        .alert("로그아웃 완료", isPresented: $showingLogoutSuccessAlert) {
            Button("확인") { }
        } message: {
            Text("로그아웃이 완료되었습니다.")
        }
        .onAppear {
            // 항상 최신 데이터 로드
            loadUserProfile()
        }
        .sheet(isPresented: $showingProfileEdit) {
            ProfileEditView(
                userProfile: userProfile,
                onSave: { name, phone, locationCity, birthDate, profileImage in
                    await updateProfile(name: name, phone: phone, locationCity: locationCity, birthDate: birthDate, profileImage: profileImage)
                }
            )
        }
        .sheet(isPresented: $showingDepositView) {
            WalletDepositView()
                .onDisappear {
                    // 충전 완료 후 잔액 새로고침
                    loadUserProfile()
                }
        }
        .sheet(isPresented: $showingWithdrawView) {
            WalletWithdrawView()
                .onDisappear {
                    // 출금 완료 후 잔액 새로고침
                    loadUserProfile()
                }
        }
    }
    
    private func loadUserProfile() {
        isLoadingProfile = true
        isLoadingWallet = true
        
        Task {
            async let profileTask = NetworkManager.shared.fetchUserProfile()
            async let walletTask = NetworkManager.shared.fetchWalletBalance()
            
            let (profile, balance) = await (profileTask, walletTask)
            
            await MainActor.run {
                self.userProfile = profile
                self.walletBalance = balance
                self.isLoadingProfile = false
                self.isLoadingWallet = false
            }
        }
    }
    
    private func updateProfile(name: String, phone: String, locationCity: String, birthDate: String, profileImage: Data?) async {
        isUpdatingProfile = true
        
        let success = await NetworkManager.shared.updateProfile(
            name: name,
            phone: phone,
            locationCity: locationCity,
            birthDate: birthDate,
            profileImage: profileImage
        )
        
        await MainActor.run {
            isUpdatingProfile = false
            if success {
                showingProfileEdit = false
                // 프로필 정보 새로고침
                print("🔄 프로필 수정 성공 - 데이터 새로고침")
                loadUserProfile()
            }
        }
    }
    
    private func performLogout() {
        isLoggingOut = true
        
        Task {
            await authViewModel.signOut()
            
            await MainActor.run {
                isLoggingOut = false
                showingLogoutSuccessAlert = true
            }
        }
    }

    private var profileCard: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
                if isLoadingProfile {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("로딩 중...")
                            .foregroundStyle(.secondary)
                    }
                } else if let profile = userProfile {
                    Text(profile.name)
                        .font(.title3)
                        .bold()
                    Text(profile.email)
                        .foregroundStyle(.secondary)
                } else {
                    Text("사용자 정보")
                        .font(.title3)
                        .bold()
                    Text("정보를 불러올 수 없습니다")
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            
            if let profile = userProfile, let profileImageUrl = profile.profileImageUrl, !profileImageUrl.isEmpty {
                AsyncImage(url: URL(string: profileImageUrl)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Circle()
                        .fill(Color.grey100)
                        .overlay(Image(systemName: "person").foregroundStyle(.secondary))
                }
                .frame(width: 48, height: 48)
                .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.grey100)
                    .frame(width: 48, height: 48)
                    .overlay(Image(systemName: "person").foregroundStyle(.secondary))
            }
        }
        .padding(16)
        .contentShape(Rectangle())
        .onTapGesture {
            showingProfileEdit = true
        }
    }

    private var accountPill: some View {
        HStack(spacing: 12) {
            Text("내 계좌").foregroundStyle(.white).bold()
            Spacer()
            if isLoadingWallet {
                Text("로딩 중...")
                    .foregroundStyle(.white)
            } else if let balance = walletBalance {
                Text("\(balance.formatted())원")
                    .foregroundStyle(.white)
            } else {
                Text("잔액 조회 실패")
                    .foregroundStyle(.white)
            }
            Capsule()
                .fill(Color.white.opacity(0.2))
                .frame(width: 1, height: 16)
            
            Button(action: {
                showingDepositView = true
            }) {
                Text("충전")
                    .foregroundStyle(.white)
                    .font(.subheadline)
            }
            .buttonStyle(PlainButtonStyle())
            
            Text("|").foregroundStyle(.white.opacity(0.6))
            
            Button(action: {
                showingWithdrawView = true
            }) {
                Text("출금")
                    .foregroundStyle(.white)
                    .font(.subheadline)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .font(.subheadline)
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .listRowInsets(EdgeInsets())
        .background(Color.purple400)
        .contentShape(Rectangle())
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
