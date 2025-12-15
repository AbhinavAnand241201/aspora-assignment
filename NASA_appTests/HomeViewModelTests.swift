import XCTest
@testable import NASA_app


class MockNetworkService: NetworkServiceProtocol {
    
    var shouldReturnError = false
    
    func fetchAPOD(date: Date?) async throws -> APODResponse {
        if shouldReturnError {
            throw APIError.serverError(statusCode: 500)
        }
        
        return APODResponse(
            copyright: "Test Copyright",
            date: "2023-10-25",
            explanation: "Test Explanation",
            hdurl: "http://test.com/hd.jpg",
            mediaType: "image",
            serviceVersion: "v1",
            title: "Test Title",
            url: "http://test.com/image.jpg"
        )
    }
}


@MainActor
final class HomeViewModelTests: XCTestCase {

    var viewModel: HomeViewModel!
    var mockService: MockNetworkService!

    override func setUp() {
        super.setUp()
        mockService = MockNetworkService()
        viewModel = HomeViewModel(networkService: mockService)
    }

    override func tearDown() {
        viewModel = nil
        mockService = nil
        super.tearDown()
    }

    func testInitialStateLoadsData() async {
       
        await viewModel.loadAPOD()
        
        XCTAssertNotNil(viewModel.apod, "APOD data should be populated on success")
        XCTAssertFalse(viewModel.isLoading, "Loading indicator should be hidden after success")
        XCTAssertNil(viewModel.errorMessage, "Error message should be nil on success")
        XCTAssertEqual(viewModel.apod?.title, "Test Title")
    }
    
    func testServerFailureShowsError() async {
        mockService.shouldReturnError = true
        
        await viewModel.loadAPOD()
        
        XCTAssertNil(viewModel.apod, "Data should be nil on failure")
        XCTAssertNotNil(viewModel.errorMessage, "Error message should be set")
        XCTAssertTrue(viewModel.errorMessage!.contains("Status Code: 500"), "Error message should match the specific error")
    }
    
    func testDateSelectionRejectsFuture() {
        let futureDate = Date().addingTimeInterval(86400 * 10) 
        let accepted = viewModel.selectDate(futureDate)
        
        XCTAssertFalse(accepted)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.errorMessage!.contains("future"))
    }
    
    func testDateSelectionRejectsBeforeMin() {
        let badDate = Calendar.current.date(from: DateComponents(year: 1990, month: 1, day: 1))!
        let accepted = viewModel.selectDate(badDate)
        
        XCTAssertFalse(accepted)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.errorMessage!.contains("1995"))
    }
    
    func testClearsAPODOnFailure() async {
        await viewModel.loadAPOD()
        XCTAssertNotNil(viewModel.apod)
        
        mockService.shouldReturnError = true
        await viewModel.loadAPOD()
        
        XCTAssertNil(viewModel.apod, "APOD should be cleared on failure")
        XCTAssertNotNil(viewModel.errorMessage)
    }
}