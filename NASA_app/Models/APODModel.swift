import Foundation

struct APODResponse: Codable, Identifiable {
    // i am using  the date as the unique ID since there is only one APOD per day
    var id: String { date }
    
    let copyright: String?
    let date: String
    let explanation: String
    let hdurl: String?
    let mediaType: String
    let serviceVersion: String
    let title: String
    let url: String

    enum CodingKeys: String, CodingKey {
        case copyright, date, explanation, hdurl
        case mediaType = "media_type"
        case serviceVersion = "service_version"
        case title, url
    }
}