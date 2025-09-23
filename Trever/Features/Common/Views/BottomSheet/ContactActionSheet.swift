import SwiftUI

struct ContactActionSheet: View {
    let phoneNumber: String
    let onCall: () -> Void
    let onMessage: () -> Void
    let onCopy: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
//            // 드래그 인디케이터
//            RoundedRectangle(cornerRadius: 2.5)
//                .fill(Color.gray.opacity(0.3))
//                .frame(width: 36, height: 5)
//                .padding(.top, 8)
            
            VStack(spacing: 0) {
                // 전화걸기 버튼
                Button(action: {
                    onCall()
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.gray)
                            .frame(width: 24)
                        Text("통화 \(phoneNumber)")
                            .foregroundColor(.primaryText)
                        Spacer()
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 20)
                }
                
                Divider()
                
                // 문자보내기 버튼
                Button(action: {
                    onMessage()
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "message.fill")
                            .foregroundColor(.gray)
                            .frame(width: 24)
                        Text("문자 \(phoneNumber)")
                            .foregroundColor(.primaryText)
                        Spacer()
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 20)
                }
                
                Divider()
                
                // 번호 복사 버튼
                Button(action: {
                    onCopy()
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "doc.on.doc.fill")
                            .foregroundColor(.gray)
                            .frame(width: 24)
                        Text("번호 복사")
                            .foregroundColor(.primaryText)
                        Spacer()
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 20)
                }
                
                Spacer()
                    .frame(height: 20)
                
                // 취소 버튼
                Button(action: { dismiss() }) {
                    Text("취소")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.errorRed)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.red, lineWidth: 1)
                        )
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .background(Color.clear)
        .presentationDetents([.fraction(0.35)])
        .presentationDragIndicator(.hidden)
    }
}

#Preview {
    ContactActionSheet(
        phoneNumber: "010-1234-5678",
        onCall: {},
        onMessage: {},
        onCopy: {}
    )
}
