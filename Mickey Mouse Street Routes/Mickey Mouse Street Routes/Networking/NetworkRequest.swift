//
//  NetworkRequest.swift
//  Mickey Mouse Street Routes
//
//  Created by Ethan Van Heerden on 11/6/23.
//

import Foundation

/// Represents an HTTP request that can be sent.
protocol NetworkRequest {
    /// The expected deserialized type of the network request.
    associatedtype Response: Decodable
    
    /// Creates a `URLRequest` used for the networking call.
    func createRequest() -> URLRequest
}
