//
//  ContentView.swift
//  Mickey Mouse Street Routes
//
//  Created by Ethan Van Heerden on 11/6/23.
//

import SwiftUI

struct ContentView: View {

    var body: some View {
        TabView {
            GoView()
                .tabItem {
                    Image(systemName: "arrowshape.bounce.right.fill")
                    Text("Go")
                }
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}
