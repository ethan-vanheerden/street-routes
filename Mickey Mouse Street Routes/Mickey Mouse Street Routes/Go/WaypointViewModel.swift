//
//  WaypointViewModel.swift
//  Mickey Mouse Street Routes
//
//  Created by Ethan Van Heerden on 11/6/23.
//

import Foundation

final class WaypointViewModel: ObservableObject {
    @Published var viewState: WaypointViewState = .loading
    
    init(teamName: String) {
        // TODO: 
    }
    
}

enum WaypointViewState {
    case loading
    case error
    case loaded(WaypointDisplay)
}

struct WaypointDisplay {
    
}
