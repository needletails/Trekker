//
//  TrekkerApp.swift
//  Trekker
//
//  Created by Cole M on 12/21/24.
//

import SwiftUI

@main
struct TrekkerApp: App {
    
    @ObservedObject var authenticationViewModel = AuthenticationViewModel()
    let networkManager = NetworkManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .background(Color.black)
                .environmentObject(authenticationViewModel)
                .onAppear {
                    authenticationViewModel.networkDelegate = networkManager
                }
        }
    }
}
