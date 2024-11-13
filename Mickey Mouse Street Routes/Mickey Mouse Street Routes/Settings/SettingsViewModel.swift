//
//  SettingsViewModel.swift
//  Mickey Mouse Street Routes
//
//  Created by Ethan Van Heerden on 11/6/23.
//

import Foundation

final class SettingsViewModel: ObservableObject {
    @Published var teamId: Int?
    
    init() {
        self.teamId = UserDefaults().integer(forKey: "team_name")
    }
    
    func updateTeamId(newId: Int) {
        UserDefaults().set(newId, forKey: "team_name")
        self.teamId = newId
    }
}

