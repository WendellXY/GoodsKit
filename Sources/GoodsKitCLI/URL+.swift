//
//  URL+.swift
//  GoodsKit
//
//  Created by Xinyu Wang on 2023/3/02
//  Copyright © 2023 Xinyu Wang. All rights reserved.
//

import Foundation

extension URL {
    /// The directory where the results are saved
    static let defaultResultSavingDirectory = Self.documentsDirectory.appendingPathComponent("GoodsKit/")

    static let configDirectory = defaultResultSavingDirectory.appendingPathComponent(".config/")

    static let configFileURL = configDirectory.appendingPathComponent("config.json")
}
