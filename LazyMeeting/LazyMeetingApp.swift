//
//  LazyMeetingApp.swift
//  LazyMeeting
//
//  Created by wentx on 2025/1/23.
//

import SwiftUI

@main
struct LazyMeetingApp: App {
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}
