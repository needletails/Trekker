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
    @State var showDeleteAccountAlert = false
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
#if canImport(UIKit)
        if let url = URL(string: address), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
#elseif canImport(AppKit)
        
#endif
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
                Section {
                    Button {
                        showDeleteAccountAlert.toggle()
                    } label: {
                        Text("Delete Account")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .listRowBackground(Color.black)
                }
            }
            .alert("Are you sure that you want to delete you account?", isPresented: $showDeleteAccountAlert) {
                VStack {
                    Button("DELETE", role: .destructive) {
                        Task.detached {
                            await authenticationViewModel.deleteAccount()
                            await MainActor.run {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                    Button("Cancel", role: .cancel) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            } message: {
                Text("Please check authentication details")
            }
#if canImport(UIKit)
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
#endif
            .onChange(of: showMyTourAdded) { oldValue, newValue in
                if newValue != .none {
                    displayAddedTourView = true
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .automatic) {
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
