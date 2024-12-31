//
//  MessagesViewModel.swift
//  Trekker
//
//  Created by NeedleTails App BrewHub on 12/31/24.
//
import SwiftUI

final class MessagesViewModel: ObservableObject {
 
    @Published var messages: [ChatMessage] = []
    @Published var createdMessage: ChatMessage?
    
    
    func sendMessage(_ message: ChatMessage) {
        if messages.contains(where: { $0 != message}) {
            messages.append(message)
        }
        createdMessage = message
    }
    
}
