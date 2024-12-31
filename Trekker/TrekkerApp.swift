//
//  TrekkerApp.swift
//  Trekker
//
//  Created by NeedleTails App BrewHub on 12/21/24.
//

import SwiftUI

@main
struct TrekkerApp: App {
    
    @ObservedObject var authenticationViewModel = AuthenticationViewModel()
    @ObservedObject var toursViewModel = ToursViewModel()
    @ObservedObject var messagesViewModel = MessagesViewModel()
    let networkManager = NetworkManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .background(Color.black)
                .environmentObject(authenticationViewModel)
                .environmentObject(toursViewModel)
                .environmentObject(messagesViewModel)
                .onAppear {
                    authenticationViewModel.networkDelegate = networkManager
                }
        }
    }
}
