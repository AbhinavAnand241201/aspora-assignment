//
//  NASA_appApp.swift
//  NASA_app
//
//  Created by ABHINAV ANAND  on 15/12/25.
//

import SwiftUI

@main
struct NASA_appApp: App {
    
    init() {
        // Configurring  global URL cache for images and API responses (used by AsyncImage and URLSession.shared)
        let memoryCapacity = 100 * 1024 * 1024 // 100 MB
        let diskCapacity = 500 * 1024 * 1024  // 500 MB
        URLCache.shared = URLCache(memoryCapacity: memoryCapacity,
                                   diskCapacity: diskCapacity,
                                   diskPath: "apod_cache")
    }
    
    var body: some Scene {
        WindowGroup {
            TabView {
            HomeView()
                    .tabItem {
                        Label("Today", systemImage: "photo")
                    }
                
                TimelineView()
                    .tabItem {
                        Label("Timeline", systemImage: "clock.arrow.circlepath")
                    }
            }
        }
    }
}
