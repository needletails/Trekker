//
//  TourItem.swift
//  Trekker
//
//  Created by Cole M on 12/23/24.
//
import Foundation

enum TourType: String, CaseIterable, Codable, Hashable {
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
    
    init(title: String = "", caption: String = "", subtitle: String = "", intro: String = "", details: [String] = [], type: TourType, size: CGSize = .init(), scheduled: Date = Date()) {
        self.title = title
        self.caption = caption
        self.subtitle = subtitle
        self.intro = intro
        self.details = details
        self.type = type
        self.size = size
        self.scheduled = scheduled
    }
}
