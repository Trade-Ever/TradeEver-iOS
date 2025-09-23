//
//  TransactionCompleteView.swift
//  Trever
//
//  Created by 채상윤 on 9/23/25.
//

import SwiftUI
import PDFKit

struct TransactionCompleteView: View {
    let contractId: Int
    let onComplete: (() -> Void)?
    @Environment(\.dismiss) private var dismiss
    
    @State private var contractData: ContractData? = nil
    @State private var pdfData: Data? = nil
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    @State private var showDownloadSuccessAlert = false
    @State private var downloadedFileName = ""
    
    var body: some View {
        NavigationView {
            if isLoading {
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: .purple400))
                    
                    Text("계약서 정보를 불러오는 중...")
                        .font(.body)
                        .foregroundColor(.secondaryText)
                    
                    Text("잠시만 기다려주세요")
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationTitle("거래 완료")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("닫기") {
                            dismiss()
                        }
                    }
                }
            } else if let errorMessage = errorMessage {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                    
                    Text("오류가 발생했습니다")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primaryText)
                    
                    Text(errorMessage)
                        .font(.body)
                        .foregroundColor(.secondaryText)
                        .multilineTextAlignment(.center)
                    
                    Button("다시 시도") {
                        Task {
                            await loadContractData()
                        }
                    }
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .navigationTitle("거래 완료")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("닫기") {
                            dismiss()
                        }
                    }
                }
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        // 성공 아이콘
                        VStack(spacing: 16) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.green)
                            
                            Text("거래가 완료되었습니다!")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                        .padding(.top, 20)
                        
                        // 계약서 정보 카드
                        if let contractData = contractData {
                            VStack(spacing: 16) {
                                // 계약서 ID
                                HStack {
                                    Text("계약서 ID")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(contractData.contractId)")
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                }
                                
                                Divider()
                                
                                // 거래 ID
                                HStack {
                                    Text("거래 ID")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(contractData.transactionId)")
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                }
                                
                                Divider()
                                
                                // 구매자
                                HStack {
                                    Text("구매자")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(contractData.buyerName)
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                }
                                
                                Divider()
                                
                                // 판매자
                                HStack {
                                    Text("판매자")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(contractData.sellerName)
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                }
                                
//                                Divider()
                                
                                // 거래 상태
//                                HStack {
//                                    Text("거래 상태")
//                                        .font(.body)
//                                        .foregroundColor(.secondaryText)
//                                    Spacer()
//                                    Text(contractData.status)
//                                        .font(.body)
//                                        .fontWeight(.medium)
//                                        .foregroundColor(.green)
//                                }
                                
                                Divider()
                                
                                // 계약서 서명 일시
                                HStack {
                                    Text("계약서 서명 일시")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(formatDate(contractData.signedAt))
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                }
                            }
                            .padding(20)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                        }
                        
                        // PDF 뷰어
                        if let pdfData = pdfData {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("계약서")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                PDFViewRepresentable(data: pdfData)
                                    .frame(height: 550)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(.separator), lineWidth: 1)
                                    )
                            }
                        }
                        
                        // 다운로드 버튼
                        if pdfData != nil {
                            Button(action: {
                                Task {
                                    await downloadPDF()
                                }
                            }) {
                                HStack {
                                    Image(systemName: "arrow.down.circle.fill")
                                    Text("PDF 다운로드")
                                }
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.purple400)
                                .cornerRadius(12)
                            }
                        }
                        
                        // 완료 버튼
                        Button(action: {
                            dismiss()
                            onComplete?()
                        }) {
                            Text("완료")
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(Color.primaryText)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.grey200.opacity(0.5))
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .navigationTitle("거래 완료")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("닫기") {
                            dismiss()
                        }
                    }
                }
            }
        }
        .onAppear {
            Task {
                await loadContractData()
            }
        }
        .alert("PDF 저장 완료", isPresented: $showDownloadSuccessAlert) {
            Button("확인") {
                showDownloadSuccessAlert = false
            }
        } message: {
            Text("계약서가 성공적으로 저장되었습니다.\n\n📁 저장 위치:\nFiles 앱 > 내 iPhone > Trever\n\n📄 파일명: \(downloadedFileName)\n\nFiles 앱에서 확인하거나 다른 앱으로 공유할 수 있습니다.")
        }
    }
    
    private func loadContractData() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
            contractData = nil
            pdfData = nil
        }
        
        do {
            let contract = await NetworkManager.shared.fetchContract(contractId: contractId)
            let pdf = await NetworkManager.shared.fetchContractPDF(contractId: contractId)
            
            await MainActor.run {
                if let contract = contract {
                    self.contractData = contract
                } else {
                    self.errorMessage = "계약서 정보를 불러올 수 없습니다."
                }
                
                if let pdf = pdf {
                    self.pdfData = pdf
                }
                
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "계약서를 불러오는 중 오류가 발생했습니다."
                self.isLoading = false
            }
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSS"
        
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "yyyy년 MM월 dd일 HH:mm"
            return displayFormatter.string(from: date)
        }
        
        return dateString
    }
    
    private func downloadPDF() async {
        guard let pdfData = pdfData else { 
            print("❌ PDF 데이터가 없습니다")
            return 
        }
        
        print("📄 PDF 다운로드 시작")
        print("   - PDF 크기: \(pdfData.count) bytes")
        
        // 파일명 생성 (계약서 ID 포함)
        let fileName = "자동차매매계약서_\(contractId).pdf"
        print("   - 파일명: \(fileName)")
        
        // Documents 디렉토리에 저장
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        do {
            // PDF 데이터를 파일에 저장
            try pdfData.write(to: fileURL)
            print("✅ PDF 파일 저장 성공: \(fileURL.path)")
            
            // 파일이 실제로 저장되었는지 확인
            if FileManager.default.fileExists(atPath: fileURL.path) {
                print("✅ 파일 존재 확인: \(fileURL.path)")
                
                // SwiftUI alert 표시
                await MainActor.run {
                    downloadedFileName = fileName
                    showDownloadSuccessAlert = true
                    print("✅ 저장 완료 알림 표시")
                }
            } else {
                print("❌ 파일 저장 실패 - 파일이 존재하지 않음")
            }
            
        } catch {
            print("❌ PDF 저장 실패: \(error)")
            print("   - Error: \(error.localizedDescription)")
        }
    }
}

// MARK: - PDFViewRepresentable
struct PDFViewRepresentable: UIViewRepresentable {
    let data: Data
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePage // 단일 페이지 모드로 변경
        pdfView.displayDirection = .vertical
        
        if let document = PDFDocument(data: data) {
            pdfView.document = document
            // 첫 번째 페이지만 표시
            if document.pageCount > 0 {
                pdfView.goToFirstPage(nil)
            }
        }
        
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        // No updates needed
    }
}

#Preview {
    TransactionCompleteView(
        contractId: 65,
        onComplete: {
            print("거래 완료 콜백 호출")
        }
    )
}
