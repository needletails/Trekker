//
//  ContentView.swift
//  Trekker
//
//  Created by NeedleTails App BrewHub on 12/21/24.
//

import SwiftUI


enum RegistrationState {
    case authenticated, unauthenticated, notRegistered, registering
}

struct ContentView: View {
    
    @EnvironmentObject var authenticationViewModel: AuthenticationViewModel
 
    
    var body: some View {
        switch authenticationViewModel.state {
        case .authenticated:
            TourView()
        case .notRegistered, .unauthenticated:
            AuthenticationView()
        case .registering:
            EmptyView()
        }
    }
}

#Preview {
    ContentView(authenticationViewModel: .init())
}
