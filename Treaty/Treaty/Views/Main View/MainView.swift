//
//  MainView.swift
//  Treaty
//
//  Created by Bennett Yetra on 1/18/23.
//

import SwiftUI

struct MainView: View {
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        // MARK: TabView With Recent Post's And Profile Tabs
        TabView{
            BarterView()
                .tabItem {
                    Image(systemName: "dollarsign.arrow.circlepath")
                    Text("Barter")
                }
            
            JournalView()
                .tabItem {
                    Image(systemName: "rectangle.and.pencil.and.ellipsis")
                    Text("Journal")
                }
            
            AccountView()
                .tabItem {
                    Image(systemName: "figure.2.arms.open")
                    Text("Profile")
                }
        }
        // Changing Tab Lable Tint to Black
        .tint(colorScheme == .light ? Color.black : Color.white)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

