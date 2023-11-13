//
//  WaypointPreviewView.swift
//  Mickey Mouse Street Routes
//
//  Created by Ethan Van Heerden on 11/8/23.
//

import SwiftUI

struct WaypointPreviewView: View {
    private let display: WaypointPreviewDisplay
    private let goAction: () -> Void
    
    init(display: WaypointPreviewDisplay,
         goAction: @escaping () -> Void) {
        self.display = display
        self.goAction = goAction
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Layout.size(1)) {
            Text("Team: \(display.teamName)")
                .bold()
                .font(.title)
            Text("🔎 Next clue: \(display.clueName)")
                .font(.title2)
            Text("ℹ️ \(display.clueInfo)")
                .font(.title3)
                .multilineTextAlignment(.leading)
            Spacer()
            locationPin
        }
    }
    
    @ViewBuilder
    private var locationPin: some View {
        HStack {
            Spacer()
            Button {
                goAction()
            } label: {
                Text("📍 Take me there")
                    .bold()
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(Layout.size(3))
                    .background {
                        RoundedRectangle(cornerRadius: Layout.size(2))
                            .fill(.green)
                    }
            }
            
//            Text("lat: \(display.clueLatitude)")
//            Text("long: \(display.clueLongitude)")
            Spacer()
        }
    }
}
