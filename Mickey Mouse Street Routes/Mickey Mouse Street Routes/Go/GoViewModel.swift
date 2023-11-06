//
//  GoViewModel.swift
//  Mickey Mouse Street Routes
//
//  Created by Ethan Van Heerden on 11/6/23.
//

import Foundation

final class GoViewModel: ObservableObject {
    @Published var viewState: GoViewState = .loading
    
    func load() {
        let teamName = UserDefaults().object(forKey: "team_name") as? String
        let display = GoViewDisplay(teamName: teamName)
        updateViewState(new: .loaded(display))
    }
    
    private func updateViewState(new: GoViewState) {
        Task(priority: .userInitiated) {
            await MainActor.run {
                self.viewState = new
            }
        }
    }
}

enum GoViewState {
    case loading
    case loaded(GoViewDisplay)
}

struct GoViewDisplay {
    let teamName: String?
}
