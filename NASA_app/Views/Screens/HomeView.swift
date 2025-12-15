import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showDatePicker = false
    @State private var showDetail = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            StarField()
                .opacity(0.6)
            
            VStack(spacing: 0) {
                HStack {
                    Text("Cosmic Gallery")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()

                    Button(action: { showDatePicker = true }) {
                        Image(systemName: "calendar")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                
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
                            .foregroundColor(.white)
                        
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
                        Spacer()
                    }
                } else if let apod = viewModel.apod {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 25) {
                            Button(action: { showDetail = true }) {
                                GeometryReader { geo in
                                    let cardWidth = geo.size.width
                                    let cardHeight = cardWidth * 0.6
                                    
                                    GlassCard {
                                        VStack(alignment: .leading, spacing: 12) {
                                            if apod.mediaType == "image" {
                                                AsyncImage(
                                                    url: URL(string: apod.url),
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
                                                        image
                                                            .resizable()
                                                            .scaledToFill()
                                                            .frame(width: cardWidth, height: cardHeight)
                                                            .clipped()
                                                            .cornerRadius(15)
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
                                                ZStack {
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
                                                }
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 6) {
                                                Text(apod.title)
                                                    .font(.title2)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.white)
                                                    .multilineTextAlignment(.leading)
                                                
                                                Text(apod.date)
                                                    .font(.subheadline)
                                                    .foregroundColor(.white.opacity(0.7))
                                            }
                                        }
                                    }
                                    .frame(width: cardWidth, height: cardHeight + 80)
                                }
                                .frame(height: UIScreen.main.bounds.width * 0.6 + 80)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            GlassCard {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Description")
                                        .font(.headline)
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    Text(apod.explanation)
                                        .font(.body)
                                        .foregroundColor(.white.opacity(0.9))
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
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 16) {
                    Capsule()
                        .fill(Color.white.opacity(0.25))
                        .frame(width: 50, height: 5)
                        .padding(.top, 8)
                    
                    Text("Select Mission Date")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    DatePicker(
                        "Select Date",
                        selection: $viewModel.selectedDate,
                        in: viewModel.allowedDateRange,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .colorScheme(.dark)
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
                .presentationDetents([.medium])
            }
        }
        .fullScreenCover(isPresented: $showDetail) {
            if let apod = viewModel.apod {
                DetailView(apod: apod)
            }
        }
        .preferredColorScheme(.dark)
        .safeAreaPadding(.bottom, 12)
    }
}
