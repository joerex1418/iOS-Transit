//
//  TransitApp.swift
//  Transit
//
//  Created by Joseph Rechenmacher on 6/3/22.
//

import SwiftUI


@main
struct TransitApp: App {
    
    @StateObject private var coreData = CoreDataManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, coreData.container.viewContext)
        }
    }
}
