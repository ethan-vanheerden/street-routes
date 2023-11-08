//
//  URLRequestBuilder.swift
//  Mickey Mouse Street Routes
//
//  Created by Ethan Van Heerden on 11/7/23.
//

import Foundation

/// Utility class to build Apple's `URLRequest` in a more convenient way.
final class URLRequestBuilder {
    private var request: URLRequest
    
    init(url: URL) {
        self.request = URLRequest(url: url)
    }
    
    /// Returns the built request.
    /// - Returns: The built request
    func build() -> URLRequest {
        return request
    }
    
    /// Sets the HTTP method of the request.
    /// - Parameter method: The `HTTPMethod` for the request
    /// - Returns: The same class instance to make method chaining possible
    func setHTTPMethod(_ method: HTTPMethod) -> Self {
        request.httpMethod = method.rawValue
        return self
    }
    
    /// Sets the content type of the request to JSON.
    /// - Returns: The same class instance to make method chaining possible
    func setJSONContent() -> Self {
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return self
    }
    
    func setBody(_ body: Encodable) -> Self {
        do {
            let encoded = try JSONEncoder().encode(body)
            request.httpBody = encoded
        } catch let error {
            print("Error encoding HTTP body: \(error)")
        }
        return self
    }
}
