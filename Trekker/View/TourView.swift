//
//  TourView.swift
//  Trekker
//
//  Created by Cole M on 12/23/24.
//

import SwiftUI

struct TourView: View {
    
    @State var showProfile = false
    
    // Define different row configurations
    var featuredRow: GridItem = GridItem(.fixed(100))
    var specialRow: GridItem = GridItem(.fixed(300))
    var popularRow: GridItem = GridItem(.fixed(200))
    
    let tours: [TourItem] = [
        TourItem(title: "First Tour", type: .featured, size: CGSize(width: 100, height: 150)),
        TourItem(title: "Second Tour", type: .special, size: CGSize(width: 300, height: 350)),
        TourItem(title: "Third Tour", type: .popular, size: CGSize(width: 200, height: 250)),
        TourItem(title: "Fourth Tour", type: .featured, size: CGSize(width: 100, height: 150)),
        TourItem(title: "Fifth Tour", type: .special, size: CGSize(width: 300, height: 350)),
    ]
    
    var groupedTours: [[TourItem]] {
        // Group tours by type
        let groupedDictionary = Dictionary(grouping: tours) { $0.type }
        // Convert the dictionary values to an array of arrays
        return TourType.allCases.compactMap { groupedDictionary[$0] }
    }
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                VStack(spacing: 8) { // Use VStack for rows
                    ForEach(0..<groupedTours.count, id: \.self) { index in
                        ScrollView(.horizontal) {
                            HStack(spacing: 8) { // Use HStack for items in each row
                                ForEach(groupedTours[index], id: \.title) { tour in
                                    NavigationLink(destination: TourDetailView(tour: tour)) {
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
        }
    }
}

#Preview {
    TourView()
}
