//
//  ContentView.swift
//  PhishWise
//
//  Created by Siddharth Sehgal on 15/09/2025.
//

import SwiftUI

// MARK: - Main Content View
/// Root view that manages the main TabView structure
struct ContentView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        MainTabView()
            .environmentObject(appViewModel)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppViewModel())
}
