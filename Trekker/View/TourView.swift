//
//  TourView.swift
//  Trekker
//
//  Created by NeedleTails App BrewHub on 12/23/24.
//

import SwiftUI

struct TourView: View {
    
    @State var showMyTourAdded: TourAdded = .none
    @State var displayAddedTourView = false
    @State var showProfile = false
    @EnvironmentObject var toursViewModel: ToursViewModel
    
    // Define different row configurations
    var featuredRow: GridItem = GridItem(.fixed(100))
    var specialRow: GridItem = GridItem(.fixed(300))
    var popularRow: GridItem = GridItem(.fixed(200))
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                VStack(spacing: 8) { // Use VStack for rows
                    ForEach(0..<toursViewModel.tours.count, id: \.self) { index in
                        ScrollView(.horizontal) {
                            HStack(spacing: 8) { // Use HStack for items in each row
                                ForEach(toursViewModel.tours[index], id: \.title) { tour in
                                    NavigationLink(destination: TourDetailView(tour: tour, showMyTourAdded: $showMyTourAdded)) {
                                        HStack {
                                            Rectangle()
                                                .fill(Color.blue)
                                                .cornerRadius(8)
                                                .frame(width: tour.size.width, height: tour.size.height)
                                                .overlay(Text(tour.title).foregroundColor(.white))
                                            Spacer()
                                        }
                                    }
                                }
                            }
                        }
                        .scrollIndicators(.hidden)
                    }
                }
                .padding()
            }
            .navigationTitle("Tour Packages")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showProfile.toggle()
                    }) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text("CM")
                                    .foregroundColor(.white)
                                    .font(.headline)
                            )
                    }
                }
            }
            .fullScreenCover(isPresented: $showProfile) {
                ProfileView()
            }
            .fullScreenCover(isPresented: $displayAddedTourView) {
                switch showMyTourAdded {
                case .showNewTour(let tourItem):
                    NavigationView {
                        TourDetailView(tour: tourItem, showMyTourAdded: $showMyTourAdded)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button(action: {
                                        showMyTourAdded = .none
                                        displayAddedTourView = false
                                    }) {
                                        Image(systemName: "chevron.left")
                                    }
                                }
                            }
                    }
                case .showPurchasedTour(let tourItem):
                    NavigationView {
                        PurchasedTourView(tour: tourItem)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button(action: {
                                        showMyTourAdded = .none
                                        displayAddedTourView = false
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
        }
        .onChange(of: showMyTourAdded) { oldValue, newValue in
            if newValue != .none {
                displayAddedTourView = true
            }
        }
    }
}

#Preview {
    TourView()
}
