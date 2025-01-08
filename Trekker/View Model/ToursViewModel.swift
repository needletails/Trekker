//
//  ToursViewModel.swift
//  Trekker
//
//  Created by NeedleTails App BrewHub on 12/31/24.
//
import SwiftUI

import SwiftUI

final class ToursViewModel: ObservableObject {
    
    @Published var tours: [[TourItem]]
    @Published var myTours: [MyTours] = [
        MyTours(label: "Past Tours", tours: []),
        MyTours(label: "Upcoming Tours", tours: []),
        MyTours(label: "Favorite Tours", tours: [])
    ]
    @Published var tourGroups: [TourGroup] = []
    
    
    // Private property to hold the initial tour data
    private static let toursData: [TourItem] = [
        TourItem(
            title: "The Enchanted Journey",
            caption: "A great tour through the heart of nature's wonders",
            subtitle: "Discover the essence of a great first tour",
            intro: "Welcome to your adventure! This immersive tour will last 8 hours and is suitable for all crowd types. Prepare to explore breathtaking landscapes, engage with local culture, and create unforgettable memories.",
            details: [
                "🌲 **Morning Hike**: Start your day with a guided hike through the lush green trails of the Enchanted Forest, where you'll encounter stunning views and diverse wildlife.",
                "🍽️ **Gourmet Picnic**: Enjoy a delicious picnic lunch featuring local delicacies, prepared by renowned chefs, amidst the serene backdrop of a picturesque meadow.",
                "🏞️ **Cultural Experience**: Participate in a traditional craft workshop led by local artisans, where you can create your own souvenir to take home.",
                "📸 **Photo Opportunities**: Capture the magic of the day with plenty of photo stops at breathtaking viewpoints, ensuring you have memories to cherish forever."
            ],
            type: .featured,
            size: CGSize(width: 100, height: 150),
            scheduled: Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
        ),
        TourItem(
            title: "The Culinary Expedition",
            caption: "A delightful journey through flavors and traditions",
            subtitle: "Savor the tastes of the region",
            intro: "Join us for a mouthwatering culinary adventure! This 6-hour tour will take you through local markets, hidden gems, and renowned eateries, perfect for food lovers and curious palates.",
            details: [
                "🍴 **Market Exploration**: Wander through vibrant local markets, sampling fresh produce and artisanal goods while learning about the region's culinary heritage.",
                "👩‍🍳 **Cooking Class**: Participate in a hands-on cooking class with a local chef, where you'll learn to prepare traditional dishes using fresh, local ingredients.",
                "🥂 **Wine Tasting**: Enjoy a guided wine tasting at a nearby vineyard, where you'll discover the art of winemaking and sample exquisite local wines.",
                "🍰 **Dessert Stop**: Indulge in a sweet treat at a famous bakery, where you can savor decadent desserts that are a must-try!"
            ],
            type: .special,
            size: CGSize(width: 300, height: 350),
            scheduled: Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
        ),
        TourItem(
            title: "The Historical Odyssey",
            caption: "A captivating journey through time",
            subtitle: "Explore the rich history of our land",
            intro: "Step back in time on this 5-hour historical tour! Perfect for history buffs and curious minds, you'll visit ancient ruins, museums, and landmarks that tell the story of our heritage.",
            details: [
                "🏛️ **Ancient Ruins**: Discover the fascinating history of ancient civilizations as you explore well-preserved ruins with a knowledgeable guide.",
                "📜 **Museum Visit**: Visit a local museum featuring artifacts and exhibits that showcase the region's rich cultural history.",
                "🗣️ **Guided Narration**: Enjoy engaging storytelling from our expert guide, who will bring history to life with captivating tales and anecdotes.",
                "📸 **Scenic Views**: Capture stunning photographs at historical landmarks, ensuring you have lasting memories of your journey through time."
            ],
            type: .popular,
            size: CGSize(width: 200, height: 250),
            scheduled: Calendar.current.date(byAdding: .weekday, value: 7, to: Date()) ?? Date()
        ),
        TourItem(
            title: "The Adventure Seekers",
            caption: "Thrilling experiences for the adventurous spirit",
            subtitle: "Get your adrenaline pumping!",
            intro: "Are you ready for an adrenaline rush? This action-packed 7-hour tour is designed for thrill-seekers and adventure lovers, featuring exciting activities that will get your heart racing.",
            details: [
                "🚴 **Mountain Biking**: Hit the trails on a guided mountain biking adventure, navigating through rugged terrain and enjoying breathtaking views.",
                "🧗 **Rock Climbing**: Challenge yourself with a rock climbing session, guided by experienced instructors who will help you reach new heights.",
                "🌊 **Water Sports**: Experience the thrill of water sports, including kayaking and paddleboarding, in crystal-clear waters.",
                "🔥 **Campfire Evening**: End the day with a cozy campfire, sharing stories and roasting marshmallows under the stars."
            ],
            type: .featured,
            size: CGSize(width: 100, height: 150),
            scheduled: Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        ),
        TourItem(
            title: "The Wildlife Safari",
            caption: "An unforgettable journey into the wild",
            subtitle: "Experience nature like never before",
            intro: "Embark on a thrilling wildlife safari! This 6-hour tour will take you deep into the heart of nature, where you'll have the chance to observe majestic animals in their natural habitat and learn about the ecosystem from expert guides.",
                    details: [
                        "🦁 **Wildlife Viewing**: Spot incredible wildlife, including lions, elephants, and giraffes, as you traverse through diverse landscapes in a comfortable safari vehicle.",
                        "🌿 **Guided Nature Walk**: Join a guided nature walk to learn about local flora and fauna, and discover the intricate relationships within the ecosystem.",
                        "📸 **Photography Tips**: Capture stunning photographs with tips from our expert wildlife photographers, ensuring you get the perfect shot of your favorite animals.",
                        "🌅 **Sunset Experience**: Conclude your safari with a breathtaking sunset view over the savannah, creating a magical end to your adventure."
                    ],
                    type: .special,
                    size: CGSize(width: 300, height: 350),
                    scheduled: Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date()
                )
            ]
    
    // Initializer
    init() {
        self.tours = ToursViewModel.groupedTours
        
        let guide = User(id: UUID(), username: "JR", isAdmin: true)
        for tour in ToursViewModel.toursData {
            tourGroups.append(.init(tour: tour, groupName: "\(guide.username)_\(tour.title)_\(tour.scheduled)", members: [], guide: guide))
        }
    }
    
    // Computed property to group tours by type
    private static var groupedTours: [[TourItem]] {
        // Group tours by type
        let groupedDictionary = Dictionary(grouping: toursData) { $0.type }
        // Convert the dictionary values to an array of arrays
        return TourType.allCases.compactMap { groupedDictionary[$0] }
    }
    
    // When we add a tour we need to do a couple things. 1.
    func addTour(_ tour: TourItem, user: User) {
        // Get the index of the TourGroup that matches the given tour ID
        guard let tourGroupIndex = self.tourGroups.firstIndex(where: { $0.tour.id == tour.id }) else {
            return // Exit if the tour group is not found
        }
        
        // Add the user to the members of the found tour group
        tourGroups[tourGroupIndex].members.append(user)
        
        // Create a MyTourGroup instance to represent the user's tour group
        let myTourGroup = MyTourGroups(
            tour: tourGroups[tourGroupIndex],
            isFavorite: false,
            isPurchased: true // Consider this a purchase point. Production apps need to handle this appropriately.
        )
        
        // Determine if the tour is upcoming or past and add it to the appropriate section
        if tour.scheduled > Date() {
            // Add to Upcoming Tours
            if let upcomingToursIndex = myTours.firstIndex(where: { $0.label == "Upcoming Tours" }) {
                myTours[upcomingToursIndex].tours.append(myTourGroup)
            }
        } else if tour.scheduled < Date() {
            // Add to Past Tours
            if let pastToursIndex = myTours.firstIndex(where: { $0.label == "Past Tours" }) {
                myTours[pastToursIndex].tours.append(myTourGroup)
            }
        }
    }

    func findTour(named name: String) -> MyTourGroups? {
        // Assuming myTours is an array of a type that contains a 'tours' property
        for tourGroup in myTours {
            if let tour = tourGroup.tours.first(where: { $0.tour.tour.title == name }) {
                return tour
            }
        }
        return nil // Return nil if no tour is found
    }
    
    // Function to remove a tour (if needed)
    func removeTour(at index: Int, from groupIndex: Int) {
        // Implement logic to remove a tour from the tours array
        // This requires careful handling to maintain the grouped structure
    }
    
    // Function to get tours of a specific type
    func tours(for type: TourType) -> [TourItem] {
        return tours.flatMap { $0 }.filter { $0.type == type }
    }
}
