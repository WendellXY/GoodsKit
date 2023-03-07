//
//  MallGeneralEvaluation.swift
//  GoodsKit
//
//  Created by Xinyu Wang on 2023/2/24
//  Copyright © 2023 Xinyu Wang. All rights reserved.
//

public struct MallGeneralEvaluation: Codable {
    public enum Level: String, Codable {
        case high = "高"
        case middle = "中"
        case low = "低"
    }

    public let logisticsSpeed: Level
    public let serviceAttitude: Level
    public let descriptionMatches: Level

    public init(_ speed: String, _ attitude: String, _ matches: String) {
        self.logisticsSpeed = Level(rawValue: speed) ?? .low
        self.serviceAttitude = Level(rawValue: attitude) ?? .low
        self.descriptionMatches = Level(rawValue: matches) ?? .low
    }
}
