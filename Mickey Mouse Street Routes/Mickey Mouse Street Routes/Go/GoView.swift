//
//  GoView.swift
//  Mickey Mouse Street Routes
//
//  Created by Ethan Van Heerden on 11/6/23.
//

import SwiftUI

struct GoView: View {
    @StateObject var viewModel: GoViewModel = GoViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.viewState {
                case .loading:
                    ProgressView()
                case.loaded(let display):
                    loadedView(display: display)
                }
            }
                .navigationTitle("🚴 Go")
        }
        .onAppear {
            self.viewModel.load()
        }
    }
    
    @ViewBuilder
    private func loadedView(display: GoViewDisplay) -> some View {
        if let teamId = display.teamId,
           !(teamId == 0){
            VStack {
                Spacer()
                Text("Team \(String(teamId))")
                    .font(.title)
                    .bold()
                NavigationLink(destination: WaypointView(teamId: teamId)) {
                    ZStack {
                        RoundedRectangle(cornerRadius: Layout.size(2))
                            .fill(.green)
                            .frame(width: 100, height: 100)
                        Text("Go")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
                Spacer()
            }
            
        } else {
            CalloutView(emoji: "⚠️", message: "No team name set yet. Please create one in settings!")
        }
    }
}
