//
//  NASA_appApp.swift
//  NASA_app
//
//  Created by ABHINAV ANAND  on 15/12/25.
//

import SwiftUI

@main
struct NASA_appApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
                .preferredColorScheme(.dark) 
        }
    }
}
