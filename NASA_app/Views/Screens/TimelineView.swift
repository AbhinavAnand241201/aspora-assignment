import SwiftUI

struct TimelineView: View {
    @State private var entries: [APODResponse] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var selectedAPOD: APODResponse?
    @State private var canLoadMorePast: Bool = true
    
    private let network = NetworkManager.shared
    private let calendar = Calendar.current
    private let minDate = Calendar.current.date(from: DateComponents(year: 1995, month: 6, day: 16))!
    private let pageSize = 10
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.opacity(0.95).ignoresSafeArea()
                
                if isLoading && entries.isEmpty {
                    ProgressView("Fetching history…")
                        .tint(.white)
                } else if let error = errorMessage, entries.isEmpty {
                    VStack(spacing: 12) {
                        Text("Couldn’t load timeline")
                            .foregroundColor(.white)
                            .font(.headline)
                        Text(error)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        Button("Retry") {
                            Task { await loadInitial() }
                        }
                        .padding(.top, 8)
                    }
                    .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(entries) { apod in
                                Button {
                                    selectedAPOD = apod
                                } label: {
                                    GlassCard {
                                        HStack(spacing: 12) {
                                            AsyncImage(url: URL(string: apod.url)) { phase in
                                                switch phase {
                                                case .empty:
                                                    ZStack {
                                                        Color.white.opacity(0.08)
                                                        ProgressView()
                                                            .tint(.white)
                                                    }
                                                case .success(let image):
                                                    image
                                                        .resizable()
                                                        .scaledToFill()
                                                case .failure:
                                                    Image(systemName: "photo.fill")
                                                        .foregroundColor(.gray)
                                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                @unknown default:
                                                    EmptyView()
                                                }
                                            }
                                            .frame(width: 80, height: 80)
                                            .clipped()
                                            .cornerRadius(10)
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(apod.title)
                                                    .font(.headline)
                                                    .foregroundColor(.primary)
                                                    .lineLimit(2)
                                                Text(apod.date)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                                if let copyright = apod.copyright {
                                                    Text("© \(copyright)")
                                                        .font(.caption2)
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                            Spacer()
                                        }
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            if canLoadMorePast {
                                if isLoading {
                                    ProgressView()
                                        .tint(.white)
                                        .padding(.vertical)
                                } else {
                                    Button {
                                        Task { await loadMorePast() }
                                    } label: {
                                        Text("Load earlier days")
                                            .font(.subheadline)
                                            .foregroundColor(.black)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(Color.white)
                                            .cornerRadius(16)
                                    }
                                    .padding(.vertical)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Cosmic Timeline")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                if entries.isEmpty {
                    await loadInitial()
                }
            }
            .sheet(item: $selectedAPOD) { apod in
                DetailView(apod: apod)
            }
        }
    }
    
    private func date(byAddingDays days: Int, to base: Date) -> Date {
        calendar.date(byAdding: .day, value: days, to: base) ?? base
    }
    
    private func loadInitial() async {
        await loadRange(endingAt: todayForAPOD())
    }
    
    private func loadMorePast() async {
        guard let last = entries.last else {
            await loadInitial()
            return
        }
        let lastDate = isoDate(from: last.date) ?? Date()
        let previousDay = date(byAddingDays: -1, to: lastDate)
        await loadRange(endingAt: previousDay)
    }
    
    private func loadRange(endingAt endDate: Date) async {
        isLoading = true
        errorMessage = nil
        
        var newEntries: [APODResponse] = []
        var currentDate = endDate
        var loaded = 0
        
        while loaded < pageSize && currentDate >= minDate {
            do {
                let apod = try await network.fetchAPOD(date: currentDate)
                newEntries.append(apod)
                loaded += 1
            } catch {
                // Skip this date but record error if nothing loads
                if newEntries.isEmpty {
                    errorMessage = error.localizedDescription
                }
            }
            currentDate = date(byAddingDays: -1, to: currentDate)
        }
        
        if newEntries.isEmpty {
            canLoadMorePast = false
        } else {
            // API returns single days; we collected newest→oldest, so keep that order by appending
            entries.append(contentsOf: newEntries)
            if currentDate < minDate {
                canLoadMorePast = false
            }
        }
        
        isLoading = false
    }
    
    private func isoDate(from string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.date(from: string)
    }
    
    private func todayForAPOD() -> Date {
        var utcCalendar = Calendar(identifier: .gregorian)
        utcCalendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        let components = utcCalendar.dateComponents([.year, .month, .day], from: Date())
        return utcCalendar.date(from: components) ?? Date()
    }
}


