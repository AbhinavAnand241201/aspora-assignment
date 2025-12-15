import SwiftUI

struct DetailView: View {
    let apod: APODResponse
    @Environment(\.dismiss) var dismiss
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if apod.mediaType == "video", let url = URL(string: apod.url) {
                SafariWebView(url: url)
                    .ignoresSafeArea()
            } else {
                GeometryReader { geo in
                    let width = geo.size.width
                    AsyncImage(
                        url: URL(string: apod.hdurl ?? apod.url),
                        transaction: .init(animation: .easeInOut(duration: 0.2))
                    ) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: width, height: width * 0.6)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: width)
                                .scaleEffect(scale)
                                .gesture(
                                    MagnificationGesture()
                                        .onChanged { value in
                                            let delta = value / lastScale
                                            lastScale = value
                                            scale *= delta
                                        }
                                        .onEnded { _ in
                                            lastScale = 1.0
                                            if scale < 1.0 {
                                                withAnimation {
                                                    scale = 1.0
                                                }
                                            }
                                        }
                                )
                                .padding()
                        case .failure:
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.red)
                                .frame(width: width, height: width * 0.6)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white.opacity(0.8))
                            .padding()
                    }
                }
                Spacer()
                
                VStack(alignment: .leading) {
                    Text(apod.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    if let copyright = apod.copyright {
                        Text("© \(copyright)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(10)
                .padding(.bottom, 50)
            }
        }
    }
}
