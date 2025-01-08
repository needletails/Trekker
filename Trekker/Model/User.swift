//
//  User.swift
//  Trekker
//
//  Created by NeedleTails App BrewHub on 12/31/24.
//
import Foundation

struct User: Codable, Identifiable, Equatable, Hashable {
    let id: UUID
    let username: String
    let passwordHash: String?
    let isAdmin: Bool
    let appleIdentifier: String?
    let metadata: Data?
    
    init(id: UUID, username: String, passwordHash: String? = nil, isAdmin: Bool, appleIdentifier: String? = nil, metadata: Data? = nil) {
        self.id = id
        self.username = username
        self.passwordHash = passwordHash
        self.isAdmin = isAdmin
        self.appleIdentifier = appleIdentifier
        self.metadata = metadata
    }
}


struct UserMetadata: Codable, Equatable {
    let id: UUID
    let nickname: String
    let profilePhoto: Data
}

struct Login: Codable {
    var username: String
    var password: String
}

struct LoginResponse: Codable {
    let user: User
    let accessToken: String
    let refreshToken: String
}

struct RegisterRequest: Codable {
    var username: String
    var password: String
    var confirmPassword: String
    var apple: String?
}

struct DeleteUser: Codable {
    var appleIdentity: String?
    var username: String?
    var passwordHash: String?
}

struct SIWA: Codable {
    var appleIdentity: String
}

struct RefreshToken: Codable {
    var token: String
}

enum SiwaType {
    case register, login
}
