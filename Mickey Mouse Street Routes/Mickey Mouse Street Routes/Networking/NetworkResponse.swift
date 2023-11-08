//
//  NetworkResponse.swift
//  Mickey Mouse Street Routes
//
//  Created by Ethan Van Heerden on 11/7/23.
//

import Foundation

/// A type to wrap the response that an API request returns.
struct NetworkResponse<N: NetworkRequest> {
    public let responseObject: N.Response
    public let statusCode: URLResponse
}
