//
//  TourDetailView.swift
//  Trekker
//
//  Created by Cole M on 12/23/24.
//

import SwiftUI

struct TourDetailView: View {
    
    var tour: TourItem
    
    var body: some View {
        VStack {
            Text(tour.title)
                .font(.largeTitle)
                .padding()
            // Add more details about the tour here
        }
        .navigationTitle(tour.title) // Set the title for the detail view
    }
}

struct ToursDetailView: View {
    
    var myTour: MyTours
    
    var body: some View {
        VStack {
            ForEach(myTour.tours) { tour in
                Text(tour.title)
                    .padding()
            }
        }
        .navigationTitle(myTour.label)
    }
}

#Preview {
    TourDetailView(tour: .init(title: "My Tour", type: .featured, size: .init(width: 100, height: 100)))
}
