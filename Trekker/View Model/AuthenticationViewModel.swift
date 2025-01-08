//
//  AuthenticationViewModel.swift
//  Trekker
//
//  Created by NeedleTails App BrewHub on 12/23/24.
//
import SwiftUI
import AuthenticationServices

final class AuthenticationViewModel: NSObject, ObservableObject {
    
    @Published var user: User?
    @Published var state: RegistrationState = .notRegistered
    var networkDelegate: NetworkManagerDelegate?
    
    
    func authenticate(
        isRegistered: Bool,
        username: String,
        password: String,
        confirmPassword: String? = nil
    ) async {
        do {
            if isRegistered {
                try await networkDelegate?.login(credentials: .init(username: username, password: password))
            } else {
                guard let confirmPassword else { return }
                try await networkDelegate?.register(
                    credentials: .init(
                        username: username,
                        password: password,
                        confirmPassword: confirmPassword,
                        apple: nil)
                )
            }
            await MainActor.run { [weak self] in
                guard let self else { return }
                state = .authenticated
            }
        } catch {
            print(error)
        }
    }
    
    func signInWithApple(isRegistered: Bool, appleIdentity: String) async {
        do {
            try await networkDelegate?.signInWithApple(type: isRegistered ? .login : .register, credentials: .init(appleIdentity: appleIdentity))
            await MainActor.run { [weak self] in
                guard let self else { return }
                state = .authenticated
            }
        } catch {
            print(error)
        }
    }
    
    func logout() async {
        do {
            try await networkDelegate?.logout()
            await MainActor.run { [weak self] in
                guard let self else { return }
                state = .unauthenticated
            }
        } catch {
            //TODO: DISPLAY ERROR
            print(error)
        }
    }
    
    func deleteAccount() async {
        do {
            try await networkDelegate?.deleteAccount()
            await MainActor.run { [weak self] in
                guard let self else { return }
                state = .notRegistered
            }
        } catch {
            //TODO: DISPLAY ERROR
            print(error)
        }
    }
    
    func updateUserMetadata(data: Data) async {
        
    }
}
