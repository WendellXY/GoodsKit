//
//  URLQueryItem.swift
//  GoodsKit
//
//  Created by Xinyu Wang on 2023/3/02
//  Copyright © 2023 Xinyu Wang. All rights reserved.
//

import Foundation

extension URLQueryItem {
    init?(key: String, value: Int?) {
        guard let value else { return nil }
        self.init(name: key, value: "\(value)")
    }

    init?(key: String, value: String?) {
        guard let value else { return nil }
        self.init(name: key, value: value)
    }
}
