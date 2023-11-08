//
//  CalloutView.swift
//  Mickey Mouse Street Routes
//
//  Created by Ethan Van Heerden on 11/7/23.
//

import SwiftUI

struct CalloutView: View {
    private let emoji: String
    private let message: String
    
    init(emoji: String, message: String) {
        self.emoji = emoji
        self.message = message
    }
    
    var body: some View {
        VStack{
            Text(emoji)
                .font(.largeTitle)
            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)
        }
    }
}
