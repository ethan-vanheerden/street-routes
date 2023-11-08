//
//  String+LocalizedError.swift
//  Mickey Mouse Street Routes
//
//  Created by Ethan Van Heerden on 11/8/23.
//

import Foundation

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}
