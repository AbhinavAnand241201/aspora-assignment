import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int)
    case decodingError
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL provided was invalid. Please check the endpoint."
        case .invalidResponse:
            return "Received an invalid response from the server."
        case .serverError(let code):
            return "Server returned an error. Status Code: \(code)"
        case .decodingError:
            return "Failed to process the data from NASA."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

protocol NetworkServiceProtocol {
    func fetchAPOD(date: Date?) async throws -> APODResponse
}

class NetworkManager: NetworkServiceProtocol {
    static let shared = NetworkManager()
    
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetchAPOD(date: Date? = nil) async throws -> APODResponse {
        var components = URLComponents(string: Constants.API.baseURL)
        var queryItems = [
            URLQueryItem(name: "api_key", value: Constants.API.key)
        ]
        
        if let date = date {
            let formatter = DateFormatter()
            formatter.dateFormat = Constants.Dates.apiFormat
            queryItems.append(URLQueryItem(name: "date", value: formatter.string(from: date)))
        }
        
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.serverError(statusCode: httpResponse.statusCode)
            }
            
            let decoder = JSONDecoder()
            return try decoder.decode(APODResponse.self, from: data)
            
        } catch let decodingError as DecodingError {
            print("Decoding Error: \(decodingError)")
            throw APIError.decodingError
        } catch {
            throw APIError.unknown(error)
        }
    }
}