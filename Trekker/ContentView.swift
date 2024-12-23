//
//  ContentView.swift
//  Trekker
//
//  Created by Cole M on 12/21/24.
//

import SwiftUI


enum RegistrationState {
    case isRegistered, notRegistered, registering
}

struct ContentView: View {
    
    @EnvironmentObject var authenticationViewModel: AuthenticationViewModel
 
    
    var body: some View {
        switch authenticationViewModel.state {
        case .isRegistered:
            TourView()
        case .notRegistered:
            AuthenticationView()
        case .registering:
            EmptyView()
        }
    }
}

#Preview {
    ContentView(authenticationViewModel: .init())
}
