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
    /// The maximum number of times the browser will try to load the same page. The default value is 3, it is suggest to keep it at 3 or above.
    ///
    /// If the browser fails to load the page for more than this number of times, it will move on to the next page.
    public static var maxRepeatedTimes = 3
    public static var productURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
}
