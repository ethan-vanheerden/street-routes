//
//  VisitClueRequest.swift
//  Mickey Mouse Street Routes
//
//  Created by Ethan Van Heerden on 11/7/23.
//

import Foundation

struct VisitClueRequest: NetworkRequest {
    typealias Response = EnableTeamResponse
    private let requestBody: VisitClueRequestBody
    
    init(requestBody: VisitClueRequestBody) {
        self.requestBody = requestBody
    }
    
    func createRequest() -> URLRequest {
        let url = ServerURL.createURL(path: "/visitClueTeam")
        return URLRequestBuilder(url: url)
            .setHTTPMethod(.post)
            .setJSONContent()
            .setBody(requestBody)
            .build()
    }
    
}

// MARK: - Body

struct VisitClueRequestBody: Codable {
    let teamId: Int
    let clueName: String
    let longitude: Double
    let latitude: Double
    
    private enum CodingKeys: String, CodingKey {
        case teamId = "team_index"
        case clueName = "clue_name"
        case longitude
        case latitude
    }
}

// MARK: Response

struct VisitClueResponse: Codable {
    let status: String
}


/*
 # disable eligibility to receive routes, e.g. if team is done while another is not. can be re-enabled either in app or on dashboard
 # responds with your next route
 @app.route("/disableTeam", methods=['POST'])
 # Expected JSON
 # {"team_name" : "XXXX", str }
 # Returns JSON
 # {"status"    : "OK"/"ERROR XX", str }
 #  ERROR CODES: 1 = missing fields, 4 = team does not exist,

 */
