//
//  PrivacySettings.swift
//  Trekker
//
//  Created by NeedleTails App BrewHub on 12/23/24.
//

import SwiftUI

struct PrivacySettings: View {
    @State private var locationEnabled: Bool = false
    @State private var notificationsEnabled: Bool = false
    @State private var dataSharingEnabled: Bool = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Notifications")) {
                    Toggle(isOn: $notificationsEnabled) {
                        Text("Enable Notifications")
                    }
                }
            }
            .navigationTitle("Privacy Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    PrivacySettings()
}
