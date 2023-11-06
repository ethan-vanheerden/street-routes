//
//  WaypointView.swift
//  Mickey Mouse Street Routes
//
//  Created by Ethan Van Heerden on 11/6/23.
//

import SwiftUI

struct WaypointView: View {
    @ObservedObject private var viewModel: WaypointViewModel
    
    init(teamName: String) {
        self.viewModel = WaypointViewModel(teamName: teamName)
    }
    
    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.viewState {
                case .loading:
                    VStack {
                        ProgressView()
                            .padding(.bottom)
                        Text("🔎 Finding next waypoint. Hang tight...")
                            .font(.headline)
                    }
                case .error:
                    EmptyView()
                case .loaded(let display):
                    EmptyView()
                }
            }
        }
        .navigationTitle("📍 Next Waypoint")
    }
}
