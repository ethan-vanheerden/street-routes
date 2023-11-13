//
//  APIInteractor.swift
//  Mickey Mouse Street Routes
//
//  Created by Ethan Van Heerden on 11/6/23.
//

import Foundation

struct APIInteractor {
    static func performRequest<R: NetworkRequest>(with request: R) async throws -> NetworkResponse<R> {
        /// Can do better error handling here if needed
        let response = try await URLSession.shared.data(for: request.createRequest())
        print(response)
        let object = try JSONDecoder().decode(R.Response.self, from: response.0)
        return NetworkResponse(responseObject: object, statusCode: response.1)
    }
}
