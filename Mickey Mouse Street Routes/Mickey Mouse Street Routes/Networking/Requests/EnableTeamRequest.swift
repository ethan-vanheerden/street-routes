//
//  EnableTeamRequest.swift
//  Mickey Mouse Street Routes
//
//  Created by Ethan Van Heerden on 11/7/23.
//

import Foundation

struct EnableTeamRequest: NetworkRequest {
    typealias Response = EnableTeamResponse
    private let requestBody: EnableTeamRequestBody
    
    init(requestBody: EnableTeamRequestBody) {
        self.requestBody = requestBody
    }
    
    func createRequest() -> URLRequest {
        let url = ServerURL.createURL(path: "/enableTeam")
        return URLRequestBuilder(url: url)
            .setHTTPMethod(.post)
            .setJSONContent()
            .setBody(requestBody)
            .build()
    }
    
}

// MARK: - Body

struct EnableTeamRequestBody: Codable {
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

struct EnableTeamResponse: Codable {
    let status: String
}
