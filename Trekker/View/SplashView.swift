//
//  SplashView.swift
//  Trekker
//
//  Created by NeedleTails App BrewHub on 12/23/24.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        VStack {
            HStack {
                Text("Trekker")
                    .font(.system(size: 46, weight: .bold, design: .rounded))
                Spacer()
            }
            .padding()
            Spacer()
          
        }
    }
}

#Preview {
    SplashView()
}
