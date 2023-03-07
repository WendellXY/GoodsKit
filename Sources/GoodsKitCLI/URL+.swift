//
//  URL+.swift
//  SuperGoodsProcessor
//
//  Created by Xinyu Wang on 2023/3/02
//  Copyright © 2023 Xinyu Wang. All rights reserved.
//

import Foundation

extension URL {
    /// The directory where the results are saved, which is also where the configuration file is located.
    static let defaultResultSavingDirectory = Self.documentsDirectory.appendingPathComponent("SuperGoodsProcessor/")
}
