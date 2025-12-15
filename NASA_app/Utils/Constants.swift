import Foundation
import SwiftUI

// Keeping global configs here to avoid hardcoding strings everywhere
struct Constants {
    struct API {
       
        static let key = "wFZo7CLG4yyvTFSNUbdFo8O9DSNdZxAhL2RmYhVG"
        static let baseURL = "https://api.nasa.gov/planetary/apod"
    }
    
    struct Dates {
        static let minDateString = "1995-06-16"
        static let displayFormat = "MMM d, yyyy"
        static let apiFormat = "yyyy-MM-dd"
    }
    
    struct UI {
        static let cornerRadius: CGFloat = 20
        static let padding: CGFloat = 16
    }
}