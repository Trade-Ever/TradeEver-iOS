import SwiftUI

// Zoomable container for any image content
private struct Zoomable<Content: View>: View {
    let content: () -> Content

    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        content()
            .scaleEffect(scale)
            .offset(offset)
            // Magnification gets high priority so pinch is always responsive
            .highPriorityGesture(
                MagnificationGesture()
                    .onChanged { value in
                        let delta = value / lastScale
                        scale = clamp(scale * delta, min: 1, max: 3)
                        lastScale = value
                    }
                    .onEnded { _ in
                        lastScale = 1
                        if scale < 1 { withAnimation { scale = 1 } }
                        if scale <= 1.01 { withAnimation(.spring()) { offset = .zero; lastOffset = .zero } }
                    }
            )
            // One finger drag only when zoomed-in. We attach it to a clear overlay
            // and toggle hit-testing so TabView paging is smooth at 1x.
            .overlay(
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                guard scale > 1.01 else { return }
                                offset = CGSize(width: lastOffset.width + value.translation.width,
                                                height: lastOffset.height + value.translation.height)
                            }
                            .onEnded { _ in
                                guard scale > 1.01 else { return }
                                lastOffset = offset
                            }
                    )
                    .allowsHitTesting(scale > 1.01)
            )
            .onTapGesture(count: 2) {
                withAnimation(.spring()) {
                    if scale > 1 { scale = 1; offset = .zero; lastOffset = .zero }
                    else { scale = 2 }
                }
            }
    }

    private func clamp(_ value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        Swift.max(min, Swift.min(value, max))
    }
}

// Helper to render either remote(url) or local asset name
private struct AnyImageView: View {
    let source: String

    var body: some View {
        if let url = URL(string: source), url.scheme?.hasPrefix("http") == true {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ZStack { Color.black.opacity(0.2); ProgressView() }
                case .success(let image):
                    image.resizable().scaledToFit()
                case .failure:
                    placeholder
                @unknown default:
                    placeholder
                }
            }
        } else if UIImage(named: source) != nil {
            Image(source).resizable().scaledToFit()
        } else {
            placeholder
        }
    }

    private var placeholder: some View {
        Rectangle().fill(Color.black.opacity(0.2))
            .overlay(Image(systemName: "photo").font(.system(size: 36)).foregroundStyle(.white.opacity(0.7)))
    }
}

struct FullscreenPhotoViewer: View {
    @Binding var isPresented: Bool
    @Binding var currentIndex: Int
    @Binding var sources: [String]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            TabView(selection: $currentIndex) {
                ForEach(Array(sources.enumerated()), id: \.offset) { idx, src in
                    GeometryReader { proxy in
                        Zoomable {
                            AnyImageView(source: src)
                                .frame(width: proxy.size.width, height: proxy.size.height)
                                .background(Color.black)
                        }
                        .frame(width: proxy.size.width, height: proxy.size.height)
                    }
                    .tag(idx)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            .ignoresSafeArea()

            if sources.isEmpty {
                ProgressView().tint(.white).scaleEffect(1.2)
            }

            // Close button
            VStack {
                HStack {
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.9))
                            .shadow(radius: 2)
                    }
                    Spacer()
                }
                .padding(.top, 12)
                .padding(.horizontal, 16)

                Spacer()

                // Index indicator
                if sources.count > 1 {
                    Text("\(currentIndex + 1) / \(sources.count)")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(8)
                        .background(Capsule().fill(Color.black.opacity(0.4)))
                        .padding(.bottom, 24)
                } else {
                    Spacer().frame(height: 24)
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var shown = true
    @Previewable @State var idx = 0
    @Previewable @State var imgs = [
        "https://picsum.photos/id/1011/1200/800",
        "https://picsum.photos/id/1024/1200/800"
    ]
    return FullscreenPhotoViewer(
        isPresented: $shown,
        currentIndex: $idx,
        sources: $imgs
    )
}
