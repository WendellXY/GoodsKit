//
//  Configuration.swift
//  SuperGoodsProcessor
//
//  Created by Xinyu Wang on 2023/2/24
//  Copyright © 2023 Xinyu Wang. All rights reserved.
//
//  swiftlint:disable force_try

import Foundation

private struct RawConfiguration: Codable {
    let clientID: String
    let clientSecret: String
    let pid: String
    let accessToken: String
    let refreshToken: String
}

public final class Configuration {
    public let clientID: String
    public let clientSecret: String
    public let pid: String
    public let accessToken: String
    public let refreshToken: String

    public static let shared = Configuration()

    private init() {
        let url = Bundle.module.url(forResource: "config", withExtension: "json") ?? Bundle.main.url(forResource: "config_spg", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let rawConfiguration = try! JSONDecoder().decode(RawConfiguration.self, from: data)
        self.clientID = rawConfiguration.clientID
        self.clientSecret = rawConfiguration.clientSecret
        self.pid = rawConfiguration.pid
        self.accessToken = rawConfiguration.accessToken
        self.refreshToken = rawConfiguration.refreshToken
    }
}
