//
//  PhishWiseApp.swift
//  PhishWise
//
//  Created by Siddharth Sehgal on 15/09/2025.
//

import SwiftUI

@main
struct PhishWiseApp: App {
    @StateObject private var appViewModel = AppViewModel()
    @StateObject private var localizationHelper = LocalizationHelper.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appViewModel)
                .environmentObject(localizationHelper)
        }
    }
}
