//
//  WaypointPreviewView.swift
//  Mickey Mouse Street Routes
//
//  Created by Ethan Van Heerden on 11/8/23.
//

import SwiftUI

struct WaypointPreviewView: View {
    private let display: WaypointPreviewDisplay
    
    init(display: WaypointPreviewDisplay) {
        self.display = display
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Layout.size(1)) {
            Text("Team \(String(display.teamId))")
                .bold()
                .font(.title)
            Text("🔎 Next clue: \(display.clueName)")
                .font(.title2)
            Text("ℹ️ \(display.clueInfo)")
                .font(.title3)
                .multilineTextAlignment(.leading)
        }
    }
}
