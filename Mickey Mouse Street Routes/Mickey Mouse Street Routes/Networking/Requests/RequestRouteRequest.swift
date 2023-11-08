//
//  RequestRouteRequest.swift
//  Mickey Mouse Street Routes
//
//  Created by Ethan Van Heerden on 11/8/23.
//

import Foundation

struct RequestRouteRequest: NetworkRequest {
    typealias Response = RequestRouteResponse
    private let requestBody: RequestRouteRequestBody
    
    init(requestBody: RequestRouteRequestBody) {
        self.requestBody = requestBody
    }
    
    func createRequest() -> URLRequest {
        let url = ServerURL.createURL(path: "/requestRoute")
        return URLRequestBuilder(url: url)
            .setHTTPMethod(.post)
            .setJSONContent()
            .setBody(requestBody)
            .build()
    }
    
}

// MARK: - Body

struct RequestRouteRequestBody: Codable {
    let teamName: String
    let longitude: Double
    let latitude: Double
    
    private enum CodingKeys: String, CodingKey {
        case teamName = "team_name"
        case longitude
        case latitude
    }
}

// MARK: Response

struct RequestRouteResponse: Codable {
    let teamName: String
    let status: String
    let clueName: String
    let clueLongitude: Double
    let clueLatitude: Double
    let clueInfo: String
    let route: [Route] // TODO
    
    private enum CodingKeys: String, CodingKey {
        case teamName = "team_name"
        case status
        case clueName = "clue_name"
        case clueLongitude = "clue_long"
        case clueLatitude = "clue_lat"
        case clueInfo = "clue_info"
        case route
    }
}
