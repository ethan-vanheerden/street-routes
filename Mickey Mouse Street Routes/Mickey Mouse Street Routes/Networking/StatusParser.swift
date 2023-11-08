//
//  StatusParser.swift
//  Mickey Mouse Street Routes
//
//  Created by Ethan Van Heerden on 11/8/23.
//

import Foundation

struct StatusParser {
    static func parseStatus(_ status: String) -> Status {
        if status == "OK" {
            return .ok
        }
        
        if status.starts(with: "ERROR") {
            let split = status.split(separator: " ")
            return .error(message: String(split[1]))
        }
        
        return .error(message: "Unknown error code")
    }
}


enum Status {
    case ok
    case error(message: String)
}
