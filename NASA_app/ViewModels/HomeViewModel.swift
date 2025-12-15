import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    
    @Published var apod: APODResponse?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    @Published var selectedDate: Date = Date()
    
    private let networkService: NetworkServiceProtocol
    private let minDate = Calendar.current.date(from: DateComponents(year: 1995, month: 6, day: 16))!
    
    init(networkService: NetworkServiceProtocol = NetworkManager.shared) {
        self.networkService = networkService
        
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
            errorMessage = "You can't see the future! Please select a past date."
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
        apod = nil
        
        do {
            let result = try await networkService.fetchAPOD(date: selectedDate)
            
            if result.mediaType == "image" || result.mediaType == "video" {
                self.apod = result
            } else {
                self.errorMessage = "Unsupported media type: \(result.mediaType)"
            }
            
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}