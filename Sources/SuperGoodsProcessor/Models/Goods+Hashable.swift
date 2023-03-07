//
//  Goods+Hashable.swift
//  SuperGoodsProcessor
//
//  Created by Xinyu Wang on 2023/3/07
//  Copyright © 2023 Xinyu Wang. All rights reserved.
//

extension Goods: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: Goods, rhs: Goods) -> Bool {
        lhs.id == rhs.id
    }
}
