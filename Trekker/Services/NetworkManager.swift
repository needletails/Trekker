//
//  NetworkManager.swift
//  Trekker
//
//  Created by NeedleTails App BrewHub on 12/23/24.
//
import Foundation
import NeedleTailCrypto

protocol NetworkManagerDelegate: Sendable {
    func login(credentials: Login) async throws
    func register(credentials: RegisterRequest) async throws
    func signInWithApple(type: SiwaType, credentials: SIWA) async throws
    func logout() async throws
    func deleteAccount() async throws
}

actor NetworkManager: NetworkManagerDelegate {
    
    let crypto = NeedleTailCrypto()
    
    func login(credentials: Login) async throws {
        let data = try JSONEncoder().encode(credentials)
        let result: Response<LoginResponse> = try await URLSession.shared.request(url: URL(string: "http://localhost:8080/api/auth/login")!, method: .post, body: data)
        let base64String = try JSONEncoder().encode(result.data).base64EncodedString()
        try await crypto.saveKeychain(item: base64String, configuration: .init(service: "user-credentials-srervice"))
        
    }
    
    func register(credentials: RegisterRequest) async throws {
        let data = try JSONEncoder().encode(credentials)
        //GENERIC DOES NOT MATTER THIS RETURNS A HTTPSTATUS
        let result: Response<LoginResponse> = try await URLSession.shared.request(url: URL(string: "http://localhost:8080/api/auth/register")!, method: .post, body: data)
        if let httpResponse = result.urlResponse as? HTTPURLResponse {
            let statusCode = httpResponse.statusCode
            // You can now check the status code
            switch statusCode {
            case 201:
                try await login(credentials: .init(username: credentials.username, password: credentials.password))
            default:
                throw URLSession.Errors.responseError("SOME ERROR", "\(statusCode)")
            }
        }
    }
    
    func refreshSession() async throws {
        guard let refreshToken = await crypto.fetchKeychainItem(configuration: .init(service: "user-credentials-srervice")) else { return }
        guard let data = Data(base64Encoded: refreshToken) else { return }
        let decoded = try JSONDecoder().decode(LoginResponse.self, from: data)
        let encoded = try JSONEncoder().encode(RefreshToken(token: decoded.refreshToken))
        let result: Response<LoginResponse> = try await URLSession.shared.request(url: URL(string: "http://localhost:8080/api/auth/refresh")!, method: .post, body: encoded)
        let base64String = try JSONEncoder().encode(result.data).base64EncodedString()
        try await crypto.saveKeychain(item: base64String, configuration: .init(service: "user-credentials-srervice"))
    }
    
    func signInWithApple(type: SiwaType, credentials: SIWA) async throws {
        switch type {
        case .register:
            let headers = ["Authorization": "Bearer \(credentials.appleIdentity)"]
            let data = try JSONEncoder().encode(credentials)
            //GENERIC DOES NOT MATTER THIS RETURNS A HTTPSTATUS
            let result: Response<LoginResponse> = try await URLSession.shared.request(url: URL(string: "http://localhost:8080/api/auth/siwa-register")!, method: .post, headers: headers, body: data)
            if let httpResponse = result.urlResponse as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode
                // You can now check the status code
                switch statusCode {
                case 201:
                    try await signInWithApple(type: .login, credentials: credentials)
                default:
                    throw URLSession.Errors.responseError("SOME ERROR", "\(statusCode)")
                }
            }
        case .login:
            let headers = ["Authorization": "Bearer \(credentials.appleIdentity)"]
            let data = try JSONEncoder().encode(credentials)
            let result: Response<LoginResponse> = try await URLSession.shared.request(url: URL(string: "http://localhost:8080/api/auth/siwa-login")!, method: .post, headers: headers, body: data)
            print(result)
            let base64String = try JSONEncoder().encode(result.data).base64EncodedString()
            try await crypto.saveKeychain(item: base64String, configuration: .init(service: "user-credentials-srervice"))
            
        }
    }
    
    func logout() async throws {
        //GENERIC DOES NOT MATTER THIS RETURNS A HTTPSTATUS
        do {
        guard let tokens = await crypto.fetchKeychainItem(configuration: .init(service: "user-credentials-srervice")) else { return }
        guard let data = Data(base64Encoded: tokens) else { return }
        let decoded = try JSONDecoder().decode(LoginResponse.self, from: data)
        let headers = ["Authorization": "Bearer \(decoded.accessToken)"]
        let refreshToken = RefreshToken(token: decoded.refreshToken)
        let tokenData = try JSONEncoder().encode(refreshToken)
        let result: Response<LoginResponse> = try await URLSession.shared.request(url: URL(string: "http://localhost:8080/api/auth/protected/logout")!, method: .post, headers: headers, body: tokenData)
        print(result)
        } catch {
          //TODO: HANDLE
        }
    }
    
    func deleteAccount() async throws {
        guard let tokens = await crypto.fetchKeychainItem(configuration: .init(service: "user-credentials-srervice")) else { return }
        guard let data = Data(base64Encoded: tokens) else { return }
        let decoded = try JSONDecoder().decode(LoginResponse.self, from: data)
        let deleteUser = DeleteUser(appleIdentity: decoded.user.appleIdentifier, username: decoded.user.username, passwordHash: decoded.user.passwordHash)
        let headers = ["Authorization": "Bearer \(decoded.accessToken)"]
        let userData = try JSONEncoder().encode(deleteUser)
        let result: Response<LoginResponse> = try await URLSession.shared.request(url: URL(string: "http://localhost:8080/api/auth/protected/delete-account")!, method: .post, headers: headers, body: userData)
        print(result)
        try await crypto.deleteKeychainItem(configuration: .init(service: "user-credentials-srervice"))
    }
    
}
