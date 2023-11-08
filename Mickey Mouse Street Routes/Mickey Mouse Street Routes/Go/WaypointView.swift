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
        Task(priority: .userInitiated) { [self] in
            await self.viewModel.load()
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.viewState {
                case .loading(let message):
                    loadingView(message: message)
                case .error(let description):
                    CalloutView(emoji: "😵", message: description)
                case .loaded(let display):
                    WaypointPreviewView(display: display)
                }
            }
        }
        .navigationTitle("📍 Next Waypoint")
    }
    
    @ViewBuilder
    private func loadingView(message: String) -> some View {
        VStack {
            ProgressView()
                .padding(.bottom)
            Text(message)
                .font(.headline)
        }
    }
}
