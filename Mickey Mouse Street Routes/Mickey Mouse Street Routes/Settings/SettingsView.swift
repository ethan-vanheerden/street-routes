//
//  SettingsView.swift
//  Mickey Mouse Street Routes
//
//  Created by Ethan Van Heerden on 11/6/23.
//

import SwiftUI

enum Team: Int, CaseIterable, Identifiable {
    case team1 = 1, team2 = 2, team3 = 3, team4 = 4
    var id: Self { self }
}

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel = SettingsViewModel()
    
    @State private var selectedTeam: Team = .team1

    var body: some View {
        NavigationStack {
            List {
                Picker("Team", selection: teamIdBinding) {
                    Text("Team 1").tag(Team.team1)
                    Text("Team 2").tag(Team.team2)
                    Text("Team 3").tag(Team.team3)
                    Text("Team 4").tag(Team.team4)
                }
            }
            .navigationTitle("⚙️ Settings")
        }
    }
    
    var teamIdBinding: Binding<Team> {
        return .init(get: { Team(rawValue: viewModel.teamId ?? 1) ?? .team1},
                     set: { viewModel.updateTeamId(newId: $0.rawValue) })
    }
}

#Preview {
    SettingsView()
}
