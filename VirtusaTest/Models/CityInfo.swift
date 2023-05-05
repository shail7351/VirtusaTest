//
//  CityInfo.swift
//  VirtusaTest
//
//  Created by Shailesh Gole on 05/05/23.
//

import Foundation

// MARK: - CityInfoElement
struct CityInfoElement: Codable {
    let name: String
    let localNames: LocalNames
    let lat, lon: Double
    let country, state: String

    enum CodingKeys: String, CodingKey {
        case name
        case localNames = "local_names"
        case lat, lon, country, state
    }
}

// MARK: - LocalNames
struct LocalNames: Codable {
    let en, zh: String
}

typealias CityInfo = [CityInfoElement]
