//
//  TourDetailView.swift
//  Trekker
//
//  Created by NeedleTails App BrewHub on 12/23/24.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(macOS)
import AppKit
#endif

enum TourAdded: Equatable {
    case showNewTour(TourItem), showPurchasedTour(MyTourGroups), none
}

struct TourDetailView: View {
    var tour: TourItem
#if canImport(UIKit)
    @State var tourImage: UIImage?
#elseif canImport(macOS)
    @State var tourImage: NSImage?
#endif
    @State var showAddedTour: Bool = false
    @State var isPurchased: Bool = false
    
    @EnvironmentObject var authenticationViewModel: AuthenticationViewModel
    @EnvironmentObject var toursViewModel: ToursViewModel
    @Environment(\.presentationMode) var presentationMode
    @Binding var showMyTourAdded: TourAdded
    
    @ViewBuilder
    var image: some View {
#if canImport(UIKit)
        if let tourImage = UIImage(data: tour.imageData) {
            Image(uiImage: tourImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            Image(systemName: "photo.badge.exclamationmark")
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
#elseif canImport(macOS)
        if let tourImage = NSImage(data: tour.imageData) {
            Image(uiImage: tourImage)
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
                
                Text(tour.caption)
                    .font(.caption)
                    .padding(.top)
                
                Text(tour.intro)
                    .font(.body)
                    .padding(.top)
                
                Text(tour.subtitle)
                    .font(.subheadline)
                    .padding()
                Divider()
                ForEach(tour.details, id: \.self) { detail in
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
                Button(action: {
                    if showMyTourAdded != .none {
                        showMyTourAdded = .none
                    }
                    if let foundTour = toursViewModel.findTour(named: tour.title) {
                            showMyTourAdded = .showPurchasedTour(foundTour)
                            showAddedTour = false
                            presentationMode.wrappedValue.dismiss()
                    } else {
                        if let user = authenticationViewModel.user {
                            toursViewModel.addTour(tour, user: user)
                        }
                        showAddedTour = true
                    }
                }) {
                    if isPurchased {
                        Text("Go To Tour")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue) // Background color for the button
                            .cornerRadius(8) // Rounded corners
                    } else {
                        Text("Add Tour")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue) // Background color for the button
                            .cornerRadius(8) // Rounded corners
                    }
                }
                .padding()
            }
            .padding()
        }
        .onAppear {
            self.isPurchased = ((toursViewModel.findTour(named: tour.title)?.isPurchased) != nil)
        }
        .alert("Added Tour", isPresented: $showAddedTour) {
            // Alert actions
            Button("Show Tour", role: .cancel) {
                // Action when OK is tapped
                if let foundTour = toursViewModel.findTour(named: tour.title) {
                    showMyTourAdded = .showNewTour(foundTour.tour.tour)
                    showAddedTour = false
                    presentationMode.wrappedValue.dismiss()
                }
            }
            Button("Dismiss", role: .destructive) {
                showAddedTour = false
            }
        } message: {
            Text("Your tour has been successfully added.")
        }
        .navigationTitle(tour.title)
    }
}


struct MyToursDetailView: View {
    
    @State var myTour: MyTours
    @Binding var showMyTourAdded: TourAdded
    
    var body: some View {
        Form {
            Section(header: Text("My Tours")) {
                ForEach(myTour.tours, id: \.self) { tour in
                    NavigationLink(destination: TourDetailView(tour: tour.tour.tour, showMyTourAdded: $showMyTourAdded)) {
                        Text(tour.tour.tour.title)
                    }
                }
            }
        }
        .navigationTitle(myTour.label)
    }
}

#Preview {
    TourDetailView(tour: .init(title: "My Tour", type: .featured, size: .init(width: 100, height: 100)), showMyTourAdded: .constant(.none))
}
