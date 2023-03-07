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
}
