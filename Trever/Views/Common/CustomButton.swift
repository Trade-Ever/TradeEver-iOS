import SwiftUI

/***
 아래와 같이 사용
 
    CustomButton(
         title: "로그인",
         action: { print("로그인") },
         fontSize: 22,
         height: 60,
         cornerRadius: 16,
     )
 */

struct CustomButton: View {
    var title: String
    var action: () -> Void
    
    // 커스텀 가능한 속성
    var fontSize: CGFloat = 20
    var fontWeight: Font.Weight = .bold
    var cornerRadius: CGFloat = 12
    var height: CGFloat = 54
    var horizontalPadding: CGFloat = 16
    var maxWidth: CGFloat? = nil
    var foregroundColor: Color = .white
    var backgroundColor: Color = .purple400
    var pressedBackgroundColor: Color? = nil
    var borderColor: Color? = nil
    var shadowColor: Color? = Color.black.opacity(0.1)
    
    // Optional leading icon
    var prefixImage: Image? = nil
    var prefixImageSize: CGFloat = 20
    var contentSpacing: CGFloat = 8
    var prefixImageTint: Color? = nil
    
    // 버튼 눌림 상태
    @State private var isPressed: Bool = false
    
    var body: some View {
            Button(action: action) {
                HStack(spacing: contentSpacing) {
                    if let img = prefixImage {
                        img
                            .resizable()
                            .scaledToFit()
                            .frame(width: prefixImageSize, height: prefixImageSize)
                            .foregroundStyle(prefixImageTint ?? foregroundColor)
                    }
                    Text(title)
                        .font(.system(size: fontSize, weight: fontWeight))
                        .foregroundColor(foregroundColor)
                }
                .frame(maxWidth: maxWidth ?? .infinity, minHeight: height, alignment: .center)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(isPressed ? (pressedBackgroundColor ?? backgroundColor) : backgroundColor)
                )
                .overlay {
                    if let borderColor {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(borderColor, lineWidth: 1)
                    }
                }
            }
            .buttonStyle(.plain) // 기본 버튼 애니메이션 제거 (iOS 15+)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .shadow(color: shadowColor ?? .clear, radius: shadowColor == nil ? 0 : 4, x: 0, y: shadowColor == nil ? 0 : 2)
            .padding(.horizontal, horizontalPadding)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged({ _ in
                        withAnimation(.easeIn(duration: 0.1)) { isPressed = true }
                    })
                    .onEnded({ _ in
                        withAnimation(.easeOut(duration: 0.1)) { isPressed = false }
                    })
            )
        }
}

#Preview {
    VStack(spacing: 16) {
        CustomButton(title: "확인") {
            print("확인 버튼 클릭")
        }
        CustomButton(title: "취소") {
            print("취소 버튼 클릭")
        }
        CustomButton(
            title: "아이콘 포함",
            action: { print("아이콘 버튼 클릭") },
            prefixImage: Image("arrow_down")
        )
    }
}
