//
//  ServerURL.swift
//  Mickey Mouse Street Routes
//
//  Created by Ethan Van Heerden on 11/7/23.
//

import Foundation

struct ServerURL {
    // TODO: This will have to be HTTPS before sensitive info can be sent/received
    static let baseServerPath = "https://hh.acetyl.net"
    
    /// Creates a URL by combining the given subpath with the `baseServerPath`.
    /// - Parameter path: The subpath to be appended to the base server path, e.g. "/my/path"
    /// - Returns: The URL to make the request
    public static func createURL(path: String) -> URL {
        if let url = URL(string: baseServerPath + path) {
            return url
        } else {
            fatalError("Unable to construct URL with path \(path).")
        }
    }
}
