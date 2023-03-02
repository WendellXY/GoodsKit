//
//  URL+.swift
//  SuperGoodsProcessor
//
//  Created by Xinyu Wang on 2023/3/02
//  Copyright © 2023 Xinyu Wang. All rights reserved.
//

import Foundation

extension URL {
    static let playgroundResourceDirectory = Self.homeDirectory.appendingPathComponent("Developer/Seller/MyPlayground.playground/Resources")

    static let defaultResultSavingDirectory = Self.documentsDirectory.appendingPathComponent("SuperGoodsProcessor/")
}
