//
//  WaypointView.swift
//  Mickey Mouse Street Routes
//
//  Created by Ethan Van Heerden on 11/6/23.
//

import SwiftUI
import MapKit

struct WaypointView: View {
    @ObservedObject private var viewModel: WaypointViewModel
    @State private var clueVisitedSheet = false
    @State private var getNewClueSheet = false
    
    init(teamName: String) {
        self.viewModel = WaypointViewModel(teamName: teamName)
        Task(priority: .userInitiated) { [self] in
            await self.viewModel.load()
        }
    }
    
    var body: some View {
        NavigationStack {
            viewStateView
        }
        .navigationTitle("📍 Next Waypoint")
        .confirmationDialog("Mark as visited?",
                            isPresented: $clueVisitedSheet) {
            Button("Visit"){
                Task(priority: .userInitiated) { [self] in
                    await self.viewModel.markClueVisited()
                }
            }
            Button("Cancel", role: .cancel) {
                clueVisitedSheet = false
            }
        }.confirmationDialog("", isPresented: $getNewClueSheet) {
            Button("Get new clue") {
                Task(priority: .userInitiated) { [self] in
                    await self.viewModel.getNewClue()
                }
            }
            Button("Cancel", role: .cancel) {
                getNewClueSheet = false
            }
        }
    }
    
    @ViewBuilder
    private var viewStateView: some View {
        switch viewModel.viewState {
        case .loading(let message):
            loadingView(message: message)
        case .error(let description):
            CalloutView(emoji: "😵", message: description)
        case .loaded(let display):
            VStack {
                Spacer()
                WaypointPreviewView(display: display)
                    .padding(.horizontal, Layout.size(2))
                Spacer()
                buttons
            }
        }
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
    
    @ViewBuilder
    private var buttons: some View {
        if viewModel.isNavigating {
            VStack {
                BigButton(text: "✅ Mark clue as visited",
                          backgroundColor: .green) {
                    clueVisitedSheet = true
                }
                BigButton(text: "❌ Request different clue",
                          backgroundColor: .green) {
                    getNewClueSheet = true
                }
            }
        } else {
            BigButton(text: "📍 Take me there",
                      backgroundColor: .green) {
                viewModel.startNavigating()
            }
        }
    }
}
