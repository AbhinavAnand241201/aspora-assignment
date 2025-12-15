import XCTest
@testable import NASA_app

final class APODModelTests: XCTestCase {

    let validJSON = """
    {
        "copyright": "Stefan Liebermann",
        "date": "2023-10-25",
        "explanation": "Spanning light-years, this cosmic cloud...",
        "hdurl": "https://apod.nasa.gov/apod/image/2310/Ghost_Liebermann_2048.jpg",
        "media_type": "image",
        "service_version": "v1",
        "title": "Ghost of Cassiopeia",
        "url": "https://apod.nasa.gov/apod/image/2310/Ghost_Liebermann_960.jpg"
    }
    """.data(using: .utf8)!

    func testAPODResponseDecoding() throws {
       
        let decoder = JSONDecoder()
        
        let apod = try decoder.decode(APODResponse.self, from: validJSON)
        
       
        XCTAssertEqual(apod.date, "2023-10-25", "Date should be decoded correctly")
        XCTAssertEqual(apod.title, "Ghost of Cassiopeia", "Title should match")
        XCTAssertEqual(apod.mediaType, "image", "Media type should be image")
        XCTAssertNotNil(apod.hdurl, "HD URL should exist")
    }
    
    func testMissingOptionalFields() throws {
     
        let jsonWithoutCopyright = """
        {
            "date": "2023-10-25",
            "explanation": "Test explanation",
            "media_type": "image",
            "service_version": "v1",
            "title": "Test Title",
            "url": "https://example.com/image.jpg"
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let apod = try decoder.decode(APODResponse.self, from: jsonWithoutCopyright)
        
       
        XCTAssertNil(apod.copyright, "Copyright should be nil when missing from JSON")
        XCTAssertEqual(apod.title, "Test Title")
    }
}
