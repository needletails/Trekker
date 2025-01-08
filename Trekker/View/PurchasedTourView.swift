//
//  PurchasedTourView.swift
//  Trekker
//
//  Created by NeedleTails App BrewHub on 12/31/24.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

struct PurchasedTourView: View {
    var tour: MyTourGroups
    
    @EnvironmentObject var toursViewModel: ToursViewModel
    @State var showDetails: Bool = false
    @State var tourIsReady: Bool = false
    @State var guide: UserMetadata?
    @State var showChatView: Bool = false
    @State var chatType: ChatType = .private
    
    @ViewBuilder
    var image: some View {
#if canImport(UIKit)
        if let tourImage = UIImage(data: tour.tour.tour.imageData) {
            Image(uiImage: tourImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            Image(systemName: "photo.badge.exclamationmark")
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
#elseif canImport(AppKit)
    if let tourImage = NSImage(data: tour.tour.tour.imageData) {
        Image(nsImage: tourImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
    } else {
        Image(systemName: "photo.badge.exclamationmark")
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
#endif
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // Use a GeometryReader only for the image
                GeometryReader { proxy in
                    image
                        .frame(width: proxy.size.width, height: proxy.size.height / 4)
                }
                .frame(height: 200)
                
                Text(tour.tour.tour.caption)
                    .font(.caption)
                    .padding(.top)
                
                Text(tour.tour.tour.intro)
                    .font(.body)
                    .padding(.top)
                
                Text(tour.tour.tour.subtitle)
                    .font(.subheadline)
                    .padding()
                Divider()
                    .padding()
                Button {
                    showDetails = true
                } label: {
                    Text("Show Details")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                Divider()
                    .padding()
                
                // Tour Title
                Text(tour.tour.tour.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.bottom, 5)
                
                // Guide Information
                Text("Tour Guide")
                    .font(.headline)
                    .padding(.bottom, 5)
                    .padding(.leading, 5)
                HStack {
#if canImport(UIKit)
                    if let guide = guide, let profileImage = UIImage(data: guide.profilePhoto) {
                        Image(uiImage: profileImage) // Assuming you have a profile image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 40, height: 40)
                            .overlay {
                                Text(String(guide?.nickname.prefix(2) ?? tour.tour.guide.username.prefix(2)))
                            }
                    }
#elseif canImport(AppKit)
                    if let guide = guide, let profileImage = NSImage(data: guide.profilePhoto) {
                        Image(nsImage: profileImage) // Assuming you have a profile image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 40, height: 40)
                            .overlay {
                                Text(String(guide?.nickname.prefix(2) ?? tour.tour.guide.username.prefix(2)))
                            }
                    }
#endif
                    Text(guide?.nickname ?? tour.tour.guide.username)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 5)
                .padding(.leading, 15)
                
                Divider()
                    .padding(.vertical, 10)
                
                // Members Section
                Text("Members")
                    .font(.headline)
                    .padding(.bottom, 5)
                    .padding(.leading, 5)
                
                ForEach(tour.tour.members, id: \.self) { member in
                    var userMetadata: UserMetadata?
                    HStack {
#if canImport(UIKit)
                        if let userMetadata = userMetadata, let profileImage = UIImage(data: userMetadata.profilePhoto) {
                            Image(uiImage: profileImage) // Assuming you have a profile image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 40, height: 40)
                                .overlay {
                                    Text(String(userMetadata?.nickname.prefix(2) ?? member.username.prefix(2)))
                                }
                        }
#elseif canImport(AppKit)
                        if let userMetadata = userMetadata, let profileImage = NSImage(data: userMetadata.profilePhoto) {
                            Image(nsImage: profileImage) // Assuming you have a profile image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 40, height: 40)
                                .overlay {
                                    Text(String(userMetadata?.nickname.prefix(2) ?? member.username.prefix(2)))
                                }
                        }
#endif
                        Text(userMetadata?.nickname ?? member.username)
                            .font(.body)
                    }
                    .padding(.vertical, 2)
                    .padding(.leading, 15)
                    .onAppear {
                        if let metadata = member.metadata {
                            let decoded = try? JSONDecoder().decode(UserMetadata.self, from: metadata)
                            userMetadata = decoded
                        }
                    }
                    
                }
                Divider()
                    .padding()
                Button {
                    chatType = .private
                    showChatView = true
                } label: {
                    Text("Chat With Guide")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                Button {
                    chatType = .group
                    showChatView = true
                } label: {
                    Text("Chat With Group")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .onAppear {
            if let metadata = tour.tour.guide.metadata {
                let decoded = try? JSONDecoder().decode(UserMetadata.self, from: metadata)
                self.guide = decoded
            }
        }
        .sheet(isPresented: $showDetails) {
            ZStack {
                VStack {
                    ForEach(tour.tour.tour.details, id: \.self) { detail in
                        if let attributedDetail = try? AttributedString(markdown: detail) {
                            Text(attributedDetail)
                                .font(.body)
                                .multilineTextAlignment(.leading)
                                .padding(.vertical, 5)
                        } else {
                            Text(detail)
                                .font(.body)
                                .multilineTextAlignment(.leading)
                                .padding(.vertical, 5)
                        }
                    }
                    Spacer()
                }
            }
            .padding()
        }
#if canImport(UIKit)
        .fullScreenCover(isPresented: $showChatView) {
            NavigationView {
                ChatView(chatType: chatType)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                showChatView = false
                            }) {
                                Image(systemName: "chevron.left")
                            }
                        }
                    }
            }
        }
#endif
    }
}
