//
//  SGPBrowsersConfiguration.swift
//  GoodsKit
//
//  Created by Xinyu Wang on 2023/3/02
//  Copyright © 2023 Xinyu Wang. All rights reserved.
//

import Foundation

public struct SGPBrowsersConfiguration {
    public static var goodsKinds: [String] = []
    public static var goodsList: [[GoodsData]] = []
    public static var maxRepeatedTimes = 3
    public static var productURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
}
