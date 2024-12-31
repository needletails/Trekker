//
//  MessageCell.swift
//  Trekker
//
//  Created by NeedleTails App BrewHub on 12/31/24.
//

import SwiftUI

struct MessageCell: View {
    let message: ChatMessage
    
    var body: some View {
        if message.sender == "Bob" {
            HStack {
                Spacer()
                Text(message.message)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        } else {
            HStack {
                Text(message.message)
                    .padding()
                    .background(Color.yellow)
                    .cornerRadius(8)
                Spacer()
            }
        }
    }
}

#Preview {
    MessageCell(message: .init(id: UUID(), message: "POPS", sender: "JR", recipient: "Bob"))
}
