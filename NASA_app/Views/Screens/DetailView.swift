import SwiftUI
import UIKit

struct DetailView: View {
    let apod: APODResponse
    @Environment(\.dismiss) var dismiss
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var showHD = false
    @State private var isDownloadingShareImage = false
    @State private var imageToShare: UIImage?
    @State private var showImageShareSheet = false
    
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
                                .scaleEffect(1.3)
                                .tint(.white)
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
                    if let hd = apod.hdurl, let hdURL = URL(string: hd) {
                        Button(action: {
                            showHD = true
                        }) {
                            Image(systemName: "rectangle.and.arrow.up.right.and.arrow.down.left")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.white.opacity(0.9))
                                .padding(10)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        .padding(.leading)
                        .padding(.top, 8)
                        .accessibilityLabel("Open HD in browser")
                        .sheet(isPresented: $showHD) {
                            SafariWebView(url: hdURL)
                                .ignoresSafeArea()
                        }
                    }
                    
                    if apod.mediaType == "video",
                       let shareURL = URL(string: apod.hdurl ?? apod.url) {
                        ShareLink(item: shareURL) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.white.opacity(0.9))
                                .padding(10)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        .padding(.top, 8)
                        .padding(.leading, hdurlPadding)
                        .accessibilityLabel("Share APOD video URL")
                    } else {
                        Button {
                            guard !isDownloadingShareImage else { return }
                            isDownloadingShareImage = true
                            
                            Task {
                                defer { isDownloadingShareImage = false }
                                guard let url = URL(string: apod.hdurl ?? apod.url) else { return }
                                do {
                                    let (data, _) = try await URLSession.shared.data(from: url)
                                    if let image = UIImage(data: data) {
                                        self.imageToShare = image
                                        self.showImageShareSheet = true
                                    }
                                } catch {
                                    // For now, just logging the error; could surface a toast or alert if desired
                                    print("Share image download failed: \(error)")
                                }
                            }
                        } label: {
                            Image(systemName: isDownloadingShareImage ? "arrow.clockwise" : "square.and.arrow.up")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.white.opacity(0.9))
                                .padding(10)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        .padding(.top, 8)
                        .padding(.leading, hdurlPadding)
                        .accessibilityLabel("Share APOD image")
                        .sheet(isPresented: $showImageShareSheet) {
                            if let image = imageToShare {
                                ActivityView(activityItems: [image])
                                    .ignoresSafeArea()
                            }
                        }
                    }
                    
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white.opacity(0.8))
                            .padding()
                    }
                    .accessibilityLabel("Close")
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
    
    private var hdurlPadding: CGFloat {
        apod.hdurl == nil ? 16 : 0
    }
}
