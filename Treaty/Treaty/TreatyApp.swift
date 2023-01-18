//
//  TreatyApp.swift
//  Treaty
//
//  Created by Bennett Yetra on 1/18/23.
//

import SwiftUI
import Firebase

@main
struct TreatyApp: App {
    init() {
        FirebaseApp.configure()
    }
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}


