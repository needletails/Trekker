//
//  TourItem.swift
//  Trekker
//
//  Created by NeedleTails App BrewHub on 12/23/24.
//
import Foundation

enum TourType: String, CaseIterable, Codable, Hashable, Equatable {
    case featured, special, popular
}

struct TourItem: Codable, Equatable, Identifiable, Hashable {
    var id = UUID()
    let title: String
    let caption: String
    let subtitle: String
    let intro: String
    let details: [String]
    let type: TourType
    let size: CGSize
    let scheduled: Date
    let imageData: Data
    
    init(title: String = "", caption: String = "", subtitle: String = "", intro: String = "", details: [String] = [], type: TourType, size: CGSize = .init(), scheduled: Date = Date(), imageData: Data = Data()) {
        self.title = title
        self.caption = caption
        self.subtitle = subtitle
        self.intro = intro
        self.details = details
        self.type = type
        self.size = size
        self.scheduled = scheduled
        self.imageData = imageData
    }
}

struct TourGroup: Codable, Identifiable, Hashable, Equatable {
    var id = UUID()
    let tour: TourItem
    let groupName: String
    var members: [User]
    let guide: User
    var groupMessages: [ChatMessage]
    var privateMessages: [ChatMessage]
    
    init(id: UUID = UUID(), tour: TourItem, groupName: String, members: [User] = [], guide: User, groupMessages: [ChatMessage] = [], privateMessages: [ChatMessage] = []) {
        self.id = id
        self.tour = tour
        self.groupName = groupName
        self.members = members
        self.guide = guide
        self.groupMessages = groupMessages
        self.privateMessages = privateMessages
    }
}
