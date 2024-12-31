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
    let metadata: Data
}


struct UserMetadata: Codable, Equatable {
    let id: UUID
    let nickname: String
    let profilePhoto: Data
}
