//
//  BigButton.swift
//  Mickey Mouse Street Routes
//
//  Created by Ethan Van Heerden on 11/15/23.
//

import Foundation
import SwiftUI

struct BigButton: View {
    private let text: String
    private let backgroundColor: Color
    private let action: () -> Void
    
    init(text: String, 
         backgroundColor: Color,
         action: @escaping () -> Void) {
        self.text = text
        self.backgroundColor = backgroundColor
        self.action = action
    }
    
    var body: some View {
        HStack {
            Spacer()
            Button {
                action()
            } label: {
                Text(text)
                    .bold()
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(Layout.size(3))
                    .background {
                        RoundedRectangle(cornerRadius: Layout.size(2))
                            .fill(backgroundColor)
                    }
            }
            Spacer()
        }
    }
}
