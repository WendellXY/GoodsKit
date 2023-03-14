//
//  Coupon.swift
//  GoodsKit
//
//  Created by Xinyu Wang on 2023/2/24
//  Copyright © 2023 Xinyu Wang. All rights reserved.
//

import Foundation

public struct Coupon: Codable {
    public let discount: Int
    public let startTime: Date
    public let endTime: Date
    public let minOrderAmount: Int
    public let remainQuantity: Int
    public let totalQuantity: Int

    public init(
        discount: Int = 0,
        startTime: Date = .now,
        endTime: Date = .now,
        minOrderAmount: Int = 0,
        remainQuantity: Int = 0,
        totalQuantity: Int = 0
    ) {
        self.discount = discount
        self.startTime = startTime
        self.endTime = endTime
        self.minOrderAmount = minOrderAmount
        self.remainQuantity = remainQuantity
        self.totalQuantity = totalQuantity
    }
}
