import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showDatePicker = false
    @State private var showDetail = false
    @AppStorage("cosmicGallery.isDarkMode") private var isDarkMode: Bool = true
    
    var body: some View {
        ZStack {
            (isDarkMode ? Color.black : Color.white)
                .ignoresSafeArea()
            
            if isDarkMode {
                StarField()
                    .opacity(0.6)
            }
            
            VStack(spacing: 0) {
                HStack {
                    Text("Cosmic Gallery")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(isDarkMode ? .white : .black)
                    
                    Spacer()
                    
                    Button(action: { isDarkMode.toggle() }) {
                        Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                            .font(.title2)
                            .foregroundColor(isDarkMode ? .yellow : .blue)
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                            )
                    }
                    
                    Button(action: { showDatePicker = true }) {
                        Image(systemName: "calendar")
                            .font(.title2)
                            .foregroundColor(isDarkMode ? .white : .black)
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    }
                    .accessibilityLabel("Open date picker")
                }
                .padding()
                .background(.ultraThinMaterial)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Cosmic Gallery header")
                
                if viewModel.isLoading {
                    Spacer()
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                        Text("Contacting NASA...")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.top)
                    }
                    Spacer()
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 20) {
                        Spacer()
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                            .shadow(color: .orange.opacity(0.5), radius: 10)
                        
                        Text("Connection Lost")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(isDarkMode ? .white : .black)
                        
                        Text(error)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: { viewModel.retry() }) {
                            Text("Retry Mission")
                                .fontWeight(.bold)
                                .padding()
                                .padding(.horizontal, 20)
                                .background(Color.white)
                                .foregroundColor(.black)
                                .cornerRadius(12)
                        }
                            .accessibilityLabel("Retry mission")
                        Spacer()
                    }
                } else if let apod = viewModel.apod {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 25) {
                            if let notice = viewModel.noticeMessage {
                                Text(notice)
                                    .font(.caption)
                                    .foregroundColor(.yellow)
                                    .padding(.horizontal)
                            }
                            Button(action: { showDetail = true }) {
                                GeometryReader { geo in
                                    let cardWidth = geo.size.width
                                    let cardHeight = cardWidth * 0.6
                                    
                                    GlassCard {
                                        VStack(alignment: .leading, spacing: 12) {
                                            if apod.mediaType == "image" {
                                                AsyncImage(
                                                    url: viewModel.previewURL(for: apod),
                                                    transaction: .init(animation: .easeInOut(duration: 0.2))
                                                ) { phase in
                                                    switch phase {
                                                    case .empty:
                                                        ZStack {
                                                            Color.white.opacity(0.05)
                                                            ProgressView()
                                                        }
                                                        .frame(width: cardWidth, height: cardHeight)
                                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                                    case .success(let image):
                                                        ZStack(alignment: .topLeading) {
                                                            image
                                                                .resizable()
                                                                .scaledToFill()
                                                                .frame(width: cardWidth, height: cardHeight)
                                                                .clipped()
                                                                .cornerRadius(15)
                                                            
                                                            mediaBadge(for: apod.mediaType)
                                                                .padding(8)
                                                        }
                                                    case .failure:
                                                        ZStack {
                                                            Color.white.opacity(0.05)
                                                            Image(systemName: "photo.fill")
                                                                .font(.largeTitle)
                                                                .foregroundColor(.gray)
                                                        }
                                                        .frame(width: cardWidth, height: cardHeight)
                                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                                    @unknown default:
                                                        EmptyView()
                                                    }
                                                }
                                            } else {
                                                ZStack(alignment: .topLeading) {
                                                    LinearGradient(
                                                        colors: [Color.purple.opacity(0.7), Color.black],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                    .frame(width: cardWidth, height: cardHeight)
                                                    .cornerRadius(15)
                                                    
                                                    VStack(spacing: 12) {
                                                        Image(systemName: "play.circle.fill")
                                                            .resizable()
                                                            .frame(width: 60, height: 60)
                                                            .foregroundColor(.white)
                                                            .shadow(radius: 10)
                                                        Text("Tap to view video")
                                                            .foregroundColor(.white.opacity(0.9))
                                                            .font(.headline)
                                                    }
                                                    
                                                    mediaBadge(for: apod.mediaType)
                                                        .padding(8)
                                                }
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 6) {
                                                Text(apod.title)
                                                    .font(.title2)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(isDarkMode ? .white : .black)
                                                    .multilineTextAlignment(.leading)
                                                
                                                Text(apod.date)
                                                    .font(.subheadline)
                                                    .foregroundColor(
                                                        isDarkMode
                                                        ? .white.opacity(0.7)
                                                        : .black.opacity(0.6)
                                                    )
                                                
                                                if let copyright = apod.copyright {
                                                    Text("© \(copyright)")
                                                        .font(.caption)
                                                        .foregroundColor(
                                                            isDarkMode
                                                            ? .white.opacity(0.6)
                                                            : .black.opacity(0.55)
                                                        )
                                                }
                                            }
                                        }
                                    }
                                    .frame(width: cardWidth, height: cardHeight + 80)
                                }
                                .frame(height: UIScreen.main.bounds.width * 0.6 + 80)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .overlay(alignment: .topTrailing) {
                                if let apod = viewModel.apod {
                                    Button(action: { viewModel.toggleFavorite(apod) }) {
                                        Image(systemName: viewModel.isFavorite(apod) ? "heart.fill" : "heart")
                                            .foregroundColor(viewModel.isFavorite(apod) ? .red : .white)
                                            .padding(10)
                                            .background(Color.black.opacity(0.55))
                                            .clipShape(Circle())
                                    }
                                    .accessibilityLabel(viewModel.isFavorite(apod) ? "Remove from favorites" : "Add to favorites")
                                    .padding(12)
                                }
                            }
                            
                            GlassCard {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Description")
                                        .font(.headline)
                                        .foregroundColor(isDarkMode ? .white.opacity(0.8) : .black.opacity(0.8))
                                    
                                    Text(apod.explanation)
                                        .font(.body)
                                        .foregroundColor(isDarkMode ? .white.opacity(0.9) : .black.opacity(0.9))
                                        .lineSpacing(6)
                                }
                            }
                            
                            Color.clear.frame(height: 50)
                        }
                        .padding()
                    }
                    .refreshable {
                        await viewModel.loadAPOD()
                    }
                }
            }
        }
        .sheet(isPresented: $showDatePicker) {
            ZStack {
                (isDarkMode ? Color.black : Color(.systemBackground))
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Capsule()
                        .fill(Color.white.opacity(0.25))
                        .frame(width: 50, height: 5)
                        .padding(.top, 16)
                    
                    Text("Select Mission Date")
                        .font(.headline)
                        .foregroundColor(isDarkMode ? .white : .primary)
                        .padding(.horizontal)
                        .padding(.top, 4)
                    
                    DatePicker(
                        "Select Date",
                        selection: $viewModel.selectedDate,
                        in: viewModel.allowedDateRange,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .colorScheme(isDarkMode ? .dark : .light)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(15)
                    .padding(.horizontal)
                    .onChange(of: viewModel.selectedDate) { oldValue, newValue in
                        if viewModel.selectDate(newValue) {
                            showDatePicker = false
                        } else {
                            viewModel.selectedDate = oldValue
                        }
                    }
                    
                    Button("Cancel") {
                        showDatePicker = false
                    }
                    .foregroundColor(.red)
                    .padding(.bottom, 8)
                }
                .presentationDetents([.medium, .large])
            }
        }
        .fullScreenCover(isPresented: $showDetail) {
            if let apod = viewModel.apod {
                DetailView(apod: apod)
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .safeAreaPadding(.bottom, 12)
        .animation(.easeInOut(duration: 0.25), value: isDarkMode)
    }
    
    @ViewBuilder
    private func mediaBadge(for mediaType: String) -> some View {
        let (icon, label): (String, String) = mediaType == "video"
        ? ("play.rectangle.fill", "Video")
        : ("photo", "Image")
        
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption2)
            Text(label)
                .font(.caption2)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.black.opacity(0.55))
        .clipShape(Capsule())
        .foregroundColor(.white)
    }
}
