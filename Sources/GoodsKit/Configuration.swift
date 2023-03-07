//
//  Configuration.swift
//  GoodsKit
//
//  Created by Xinyu Wang on 2023/2/24
//  Copyright © 2023 Xinyu Wang. All rights reserved.
//
//  swiftlint:disable force_try

import Foundation

public final class Configuration: Codable {
    public let clientID: String
    public let clientSecret: String
    public let pid: String
    public let accessToken: String
    public let refreshToken: String

    public static let shared = load()

    public static let sample = {
        let url = Bundle.module.url(forResource: "config.sample", withExtension: "json")!
        return load(from: url)
    }()

    public static let defaultConfigURL = {
        if let url = Bundle.module.url(forResource: "config", withExtension: "json") {
            return url
        } else if let url = Bundle.main.url(forResource: "config_spg", withExtension: "json") {
            return url
        } else {
            return .documentsDirectory.appendingPathComponent("GoodsKit/config.json")
        }
    }()

    public static func load(from url: URL = defaultConfigURL) -> Configuration {
        let data = try! Data(contentsOf: url)
        let configuration = try! JSONDecoder().decode(Configuration.self, from: data)
        return configuration
    }
}
