//
//  ProfileView.swift
//  Trekker
//
//  Created by NeedleTails App BrewHub on 12/23/24.
//

import SwiftUI


struct MyTourGroups: Codable, Equatable, Hashable {
    var id = UUID()
    var tour: TourGroup
    var isFavorite: Bool
    var isPurchased: Bool
}

struct MyTours: Codable, Equatable, Hashable {
    var id = UUID()
    let label: String
    var tours: [MyTourGroups]
}

struct ProfileView: View {
   
    @State var showMyTourAdded: TourAdded = .none
    @State var displayAddedTourView = false
    @EnvironmentObject var authenticationViewModel: AuthenticationViewModel
    @EnvironmentObject var toursViewModel: ToursViewModel
    @Environment(\.presentationMode) var presentationMode
    let settingsItems = ["Edit Profile", "Privacy Settings"]
   
    
    @ViewBuilder
    func getSettingsDetail(settingsItem: String) -> some View {
        if settingsItem == "Edit Profile" {
            EditProfile()
        } else if settingsItem == "Privacy Settings" {
            PrivacySettings()
        } else {
            ProfileView()
        }
    }
    
    func openWebsite(address: String) {
        if let url = URL(string: address), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
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
                    Button {
                        openWebsite(address: "https://needletails.com")
                    } label: {
                        Text("Support")
                    }
                }
                
                Section(header: Text("My Tours")) {
                    ForEach(toursViewModel.myTours, id: \.self) { tour in
                        NavigationLink(destination: MyToursDetailView(myTour: tour, showMyTourAdded: $showMyTourAdded)) {
                            Text(tour.label)
                        }
                    }
                }
                
                Section {
                    Button {
                        Task.detached {
                            await authenticationViewModel.logout()
                            await MainActor.run {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    } label: {
                        Text("Logout")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .listRowBackground(Color.black)
                }
            }
            .fullScreenCover(isPresented: $displayAddedTourView) {
                switch showMyTourAdded {
                case .showPurchasedTour(let tourItem):
                    NavigationView {
                        PurchasedTourView(tour: tourItem)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button(action: {
                                        displayAddedTourView = false
                                        showMyTourAdded = .none
                                    }) {
                                        Image(systemName: "chevron.left")
                                    }
                                }
                            }
                    }
                default:
                    EmptyView()
                }
            }
            .onChange(of: showMyTourAdded) { oldValue, newValue in
                if newValue != .none {
                    displayAddedTourView = true
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
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
