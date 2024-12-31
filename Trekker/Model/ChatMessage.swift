//
//  ChatMessage.swift
//  Trekker
//
//  Created by NeedleTails App BrewHub on 12/31/24.
//
import Foundation

struct ChatMessage: Codable, Identifiable, Equatable, Hashable {
    let id: UUID
    var message: String
    let sender: String
    let recipient: String
}
