import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    
    @Published var apod: APODResponse?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var noticeMessage: String?
    @Published private(set) var favorites: Set<String> = []
    
    @Published var selectedDate: Date = Date()
    
    private let networkService: NetworkServiceProtocol
    private let minDate = Calendar.current.date(from: DateComponents(year: 1995, month: 6, day: 16))!
    
    private let favoritesKey = "apod.favorites"
    private let cacheKey = "apod.lastResponse"
    
    init(networkService: NetworkServiceProtocol = NetworkManager.shared) {
        self.networkService = networkService
        loadFavorites()
        
        Task {
            await loadAPOD()
        }
    }
    
    var allowedDateRange: ClosedRange<Date> {
        minDate...Date()
    }
    
    @discardableResult
    func selectDate(_ date: Date) -> Bool {
        guard date <= Date() else {
            errorMessage = " Please select a valid date."
            return false
        }
        
        guard date >= minDate else {
            errorMessage = "NASA's APOD archive only goes back to June 16, 1995."
            return false
        }
        
        selectedDate = date
        Task { await loadAPOD() }
        return true
    }
    
    func retry() {
        Task { await loadAPOD() }
    }
    
    func loadAPOD() async {
        isLoading = true
        errorMessage = nil
        noticeMessage = nil
        apod = nil
        
        do {
            let result = try await networkService.fetchAPOD(date: selectedDate)
            
            if result.mediaType == "image" || result.mediaType == "video" {
                self.apod = result
                cacheAPOD(result)
            } else {
                self.errorMessage = "Unsupported media type: \(result.mediaType)"
            }
            
        } catch {
            if let cached = loadCachedAPOD() {
                self.apod = cached
                self.noticeMessage = "Offline: showing last saved APOD"
            } else {
                self.errorMessage = error.localizedDescription
            }
        }
        
        isLoading = false
    }
    
    func previewURL(for apod: APODResponse) -> URL? {
        if apod.mediaType == "video" {
            if let youtube = youtubeThumbnailURL(from: apod.url) {
                return youtube
            }
        }
        return URL(string: apod.url)
    }
    
    func toggleFavorite(_ apod: APODResponse) {
        if favorites.contains(apod.id) {
            favorites.remove(apod.id)
        } else {
            favorites.insert(apod.id)
        }
        saveFavorites()
    }
    
    func isFavorite(_ apod: APODResponse) -> Bool {
        favorites.contains(apod.id)
    }
    
    private func saveFavorites() {
        let array = Array(favorites)
        UserDefaults.standard.set(array, forKey: favoritesKey)
    }
    
    private func loadFavorites() {
        if let stored = UserDefaults.standard.array(forKey: favoritesKey) as? [String] {
            favorites = Set(stored)
        }
    }
    
    private func cacheAPOD(_ apod: APODResponse) {
        if let data = try? JSONEncoder().encode(apod) {
            UserDefaults.standard.set(data, forKey: cacheKey)
        }
    }
    
    private func loadCachedAPOD() -> APODResponse? {
        guard let data = UserDefaults.standard.data(forKey: cacheKey) else { return nil }
        return try? JSONDecoder().decode(APODResponse.self, from: data)
    }
    
    private func youtubeThumbnailURL(from urlString: String) -> URL? {
        guard let url = URL(string: urlString) else { return nil }
        if url.host?.contains("youtube.com") == true || url.host?.contains("youtu.be") == true {
            var videoID: String?
            if url.host?.contains("youtu.be") == true {
                videoID = url.pathComponents.dropFirst().first
            } else {
                videoID = URLComponents(url: url, resolvingAgainstBaseURL: false)?
                    .queryItems?
                    .first(where: { $0.name == "v" })?
                    .value
            }
            if let id = videoID {
                return URL(string: "https://img.youtube.com/vi/\(id)/hqdefault.jpg")
            }
        }
        return nil
    }
}