//
//  SettingsView.swift
//  Mickey Mouse Street Routes
//
//  Created by Ethan Van Heerden on 11/6/23.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel = SettingsViewModel()
    var body: some View {
        NavigationStack {
            List {
                Section("Team Name") {
                    TextField("Team name", text: teamNameBinding)
                }
            }
            .navigationTitle("⚙️ Settings")
        }
    }
    
    var teamNameBinding: Binding<String> {
        return .init(get: { viewModel.teamName ?? ""},
                     set: { viewModel.updateTeamName(newName: $0)})
    }
}
