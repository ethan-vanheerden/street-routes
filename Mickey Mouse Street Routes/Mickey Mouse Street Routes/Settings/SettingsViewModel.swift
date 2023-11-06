//
//  SettingsViewModel.swift
//  Mickey Mouse Street Routes
//
//  Created by Ethan Van Heerden on 11/6/23.
//

import Foundation

final class SettingsViewModel: ObservableObject {
    @Published var teamName: String?
    
    init() {
        self.teamName = UserDefaults().string(forKey: "team_name")
    }
    
    func updateTeamName(newName: String) {
        UserDefaults().set(newName, forKey: "team_name")
        self.teamName = newName
    }
}
