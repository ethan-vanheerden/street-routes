//
//  Route.swift
//  Mickey Mouse Street Routes
//
//  Created by Ethan Van Heerden on 11/7/23.
//

import Foundation

struct Route: Decodable {
    let distance: Double
    let duration: Double
    let coordinates: [Coordinate]

    private enum CodingKeys: String, CodingKey {
        case distance, duration, geometry
    }

    private enum GeometryCodingKeys: String, CodingKey {
        case coordinates
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        distance = try container.decode(Double.self, forKey: .distance)
        duration = try container.decode(Double.self, forKey: .duration)

        // Decode the "geometry" container
        let geometryContainer = try container.nestedContainer(keyedBy: GeometryCodingKeys.self, forKey: .geometry)

        // Decode the "coordinates" array
        var nestedCoordinates = try geometryContainer.nestedUnkeyedContainer(forKey: .coordinates)

        // Decode each coordinate array
        var decodedCoordinates: [Coordinate] = []
        
        while !nestedCoordinates.isAtEnd {
            let coordinateArray = try nestedCoordinates.decode([Double].self)
            guard coordinateArray.count == 2 else {
                throw DecodingError.dataCorruptedError(forKey: .coordinates, in: geometryContainer, 
                                                       debugDescription: "Invalid coordinate array")
            }

            let longitude = coordinateArray[0]
            let latitude = coordinateArray[1]

            let coordinate = Coordinate(latitude: latitude, longitude: longitude)
            decodedCoordinates.append(coordinate)
        }

        coordinates = decodedCoordinates
    }
}

struct Coordinate: Codable {
    let latitude: Double
    let longitude: Double
}
