//
//  UpdateTeamLocationRequest.swift
//  Mickey Mouse Street Routes
//
//  Created by Nikhil Goel on 11/13/24.
//

import Foundation

struct UpdateTeamLocationRequest: NetworkRequest {
    typealias Response = UpdateTeamLocationResponse
    private let requestBody: UpdateTeamLocationRequestBody
    
    init(requestBody: UpdateTeamLocationRequestBody) {
        self.requestBody = requestBody
    }
    
    func createRequest() -> URLRequest {
        let url = ServerURL.createURL(path: "/updateTeamLocation")
        return URLRequestBuilder(url: url)
            .setHTTPMethod(.post)
            .setJSONContent()
            .setBody(requestBody)
            .build()
    }
    
}

// MARK: - Body

struct UpdateTeamLocationRequestBody: Codable {
    let teamId: Int
    let longitude: Double
    let latitude: Double
    
    private enum CodingKeys: String, CodingKey {
        case teamId = "team_index"
        case longitude
        case latitude
    }
}

// MARK: Response

struct UpdateTeamLocationResponse: Codable {
    let status: String
}

