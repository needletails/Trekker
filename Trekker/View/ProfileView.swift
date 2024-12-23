//
//  ProfileView.swift
//  Trekker
//
//  Created by Cole M on 12/23/24.
//

import SwiftUI

struct MyTours: Equatable, Hashable {
    var id = UUID()
    let label: String
    var tours: [TourItem]
}

struct ProfileView: View {
    @EnvironmentObject var authenticationViewModel: AuthenticationViewModel
    @Environment(\.presentationMode) var presentationMode
    let settingsItems = ["Edit Profile", "Support", "Privacy Settings"]
    @State var tourItems: [MyTours] = [
        MyTours(label: "Past Tours", tours: []),
        MyTours(label: "Upcoming Tours", tours: []),
        MyTours(label: "Favorite Tours", tours: [])
    ]
    
    @ViewBuilder
    func getSettingsDetail(settingsItem: String) -> some View {
        if settingsItem == "Edit Profile" {
            EditProfile()
        } else if settingsItem == "Support" {
            Support()
        } else if settingsItem == "Privacy Settings" {
            PrivacySettings()
        } else {
            ProfileView()
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("My Settings")) {
                    
                    ForEach(settingsItems, id: \.self) { item in
                        NavigationLink(destination: getSettingsDetail(settingsItem: item)) {
                            Text(item)
                        }
                    }
                }
                
                Section(header: Text("My Tours")) {
                    ForEach(tourItems, id: \.self) { tour in
                        NavigationLink(destination: ToursDetailView(myTour: tour)) {
                            Text(tour.label)
                        }
                    }
                }
                
                Section {
                    Button(action: {
                        // Action to perform when the button is tapped
                        Task.detached {
                            await authenticationViewModel.logout()
                            await MainActor.run {
                                presentationMode.wrappedValue.dismiss() // Dismiss the view
                            }
                        }
                    }) {
                        Text("Logout")
                            .foregroundColor(.red) // Change text color to red for logout
                            .frame(maxWidth: .infinity, alignment: .center) // Center the text
                    }
                }
            }
            .onAppear {
                
                tourItems = tourItems.map { item in
                    var item = item
                    item.tours.removeAll() // Clear the tours for each item
                    return item // Return the modified item
                }
                
                let currentDate = Date()
                let calendar = Calendar.current
                var updatedTourItems = tourItems
                
                if let index = updatedTourItems.firstIndex(where: { $0.label == "Past Tours" }) {
                    var pastTours = updatedTourItems[index]
                    
                    // Subtract 7 days from the current date to create a past date
                    if let pastDate = calendar.date(byAdding: .day, value: -7, to: currentDate) {
                        pastTours.tours.append(contentsOf: [
                            TourItem(title: "Excusion One", type: .featured, scheduled: pastDate),
                            TourItem(title: "Excusion Two", type: .featured, scheduled: pastDate),
                            TourItem(title: "Excusion Three", type: .featured, scheduled: pastDate)
                        ])
                    }
                    updatedTourItems[index] = pastTours
                }
                
                if let index = updatedTourItems.firstIndex(where: { $0.label == "Upcoming Tours" }) {
                    var upcomingTours = updatedTourItems[index]
                    
                    if let futureDate = calendar.date(byAdding: .day, value: +7, to: currentDate) {
                        upcomingTours.tours.append(contentsOf: [
                            TourItem(title: "Excusion Four", type: .featured, scheduled: futureDate),
                            TourItem(title: "Excusion Five", type: .special, scheduled: futureDate),
                            TourItem(title: "Excusion Six", type: .popular, scheduled: futureDate)
                        ])
                    }
                    updatedTourItems[index] = upcomingTours
                }
                
                if let index = updatedTourItems.firstIndex(where: { $0.label == "Favorite Tours" }) {
                   var favoriteTours = updatedTourItems[index]
                    
                    favoriteTours.tours.append(contentsOf: [
                        TourItem(title: "Excusion Seven", type: .popular),
                        TourItem(title: "Excusion Eight", type: .popular),
                        TourItem(title: "Excusion Six", type: .popular)
                    ])
                    updatedTourItems[index] = favoriteTours
                }
                tourItems = updatedTourItems
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { // Use .navigationBarLeading for top bar
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileView()
    
}
