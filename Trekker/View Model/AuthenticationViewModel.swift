//
//  AuthenticationViewModel.swift
//  Trekker
//
//  Created by Cole M on 12/23/24.
//
import SwiftUI

final class AuthenticationViewModel: ObservableObject {
    
    @Published var state: RegistrationState = .notRegistered
    var networkDelegate: NetworkManagerDelegate?
    
    
    func authenticate(isRegistered: Bool) async {
        await MainActor.run { [weak self] in
            guard let self else { return }
            state = .isRegistered
        }
        if isRegistered {
            await networkDelegate?.login()
        } else {
            await networkDelegate?.register()
        }
    }
    
    func signInWithApple(isRegistered: Bool) async {
        await MainActor.run { [weak self] in
            guard let self else { return }
            state = .isRegistered
        }
        if isRegistered {
            await networkDelegate?.signInWithApple()
        } else {
            
        }
    }
    
    func logout() async {
        await MainActor.run { [weak self] in
            guard let self else { return }
            state = .notRegistered
        }
        await networkDelegate?.logout()
    }
    
}
