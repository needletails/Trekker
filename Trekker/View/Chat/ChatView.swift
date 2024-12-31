//
//  ChatView.swift
//  Trekker
//
//  Created by NeedleTails App BrewHub on 12/31/24.
//

import SwiftUI

enum ChatType {
    case `private`, group
}

struct ChatView: View {
    
    let chatType: ChatType
    
    @EnvironmentObject var messagesViewModel: MessagesViewModel
    @State private var messages: [ChatMessage] = []
    @State private var newMessage: String = ""
    @State private var editableMessage: ChatMessage?
    @State private var showEditMessageSheet: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    ForEach(messages.lazy, id: \.id) { message in
                        MessageCell(message: message)
                            .id(message.id)
                            .contextMenu {
                                if message.sender == "Bob" {
                                    Button {
                                        editableMessage = message
                                        showEditMessageSheet = true
                                    } label: {
                                        Text("Edit")
                                        Image(systemName: "pencil")
                                    }
                                }
                                Button {
                                    deleteMessage(message)
                                } label: {
                                    Text("Delete")
                                    Image(systemName: "trash")
                                }
                            }
                    }
                    .padding()
                    Spacer()
                }
                // Text input field and send button
                HStack {
                    TextField("Type a message...", text: $newMessage)
                        .background(Color.gray)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    Circle()
                        .fill(.blue)
                        .frame(width: 30, height: 30)
                        .overlay {
                            Image(systemName: "paperplane.fill")
                        }
                        .onTapGesture {
                            sendMessage()
                        }
                        .padding(.trailing)
                }
                .padding()
                .background(Color.gray)
            }
            .navigationTitle(chatType == .group ? "Group Chat" : "Private Chat")
        }
        .onAppear {
            self.messages = messagesViewModel.messages
        }
        .onReceive(messagesViewModel.$createdMessage) { message in
            guard let message = message else { return }
            self.messages.append(message)
        }
        .sheet(isPresented: $showEditMessageSheet) {
            VStack {
                Spacer()
                HStack {
                    TextField("Edit a message...", text: $newMessage)
                        .background(Color.gray)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    Circle()
                        .fill(.blue)
                        .frame(width: 30, height: 30)
                        .overlay {
                            Image(systemName: "paperplane.fill")
                        }
                        .onTapGesture {
                            if !newMessage.isEmpty, let editableMessage = editableMessage {
                                editMessage(editableMessage)
                            }
                        }
                        .padding(.trailing)
                }
                .background(Color.gray)
                Spacer()
            }
            .padding()
            .background(Color.gray)
            .presentationDetents([.height(UIScreen.main.bounds.height / 8)])
        }
    }
    
    // Function to send a message
    private func sendMessage() {
        guard !newMessage.isEmpty else { return }
        let bobs = ChatMessage(id: UUID(), message: newMessage, sender: "Bob", recipient: "JR")
        let jrs = ChatMessage(id: UUID(), message: newMessage, sender: "JR", recipient: "Bob")
        messagesViewModel.sendMessage(bobs)
        messagesViewModel.sendMessage(jrs)
        newMessage = ""
    }
    
    private func editMessage(_ message: ChatMessage) {
        if let index = messages.firstIndex(where: { $0.id == message.id }) {
            messages[index].message = newMessage
        }
        if let index = messagesViewModel.messages.firstIndex(where: { $0.id == message.id }) {
            messagesViewModel.messages[index].message = newMessage
        }
        showEditMessageSheet = false
        newMessage = ""
    }
    
    private func deleteMessage(_ message: ChatMessage) {
        messages.removeAll { $0.id == message.id }
        messagesViewModel.messages.removeAll { $0.id == message.id }
    }
}
