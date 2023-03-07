//
//  GoodsData.swift
//  GoodsKit
//
//  Created by Xinyu Wang on 2023/2/27
//  Copyright © 2023 Xinyu Wang. All rights reserved.
//

import Foundation

public struct GoodsCommentsTag: Codable, Hashable {
    public let name: String
    public let num: Int
    public let positive: Int
}

public struct GoodsData: Codable {
    public let id: Int
    public let goodsDetails: URL
}

public struct GoodsDetailData: Codable, Hashable {
    public let id: Int
    public let tagList: [GoodsCommentsTag]
    public let skuList: [String: Double]

    public var goodCommentsRate: Double {
        guard !tagList.isEmpty else { return -1 }

        let badCommentsAmount = tagList.filter { $0.positive == 0 }.reduce(0) { $0 + $1.num }

        if let allCommentsTag = tagList.first(where: { $0.name == "全部" }) {
            return Double(allCommentsTag.num - badCommentsAmount) / Double(allCommentsTag.num)
        } else {
            let allCommentsAmount = tagList.map(\.num).reduce(0, +)
            return Double(allCommentsAmount - badCommentsAmount) / Double(allCommentsAmount)
        }
    }
}

public struct GoodsShowcase: CSVEncodable {
    public let goods: Goods
    public let skuName: String
    public let skuPrice: Double
    public let goodCommentsRate: Double

    public init(goods: Goods, skuName: String, skuPrice: Double, goodCommentsRate: Double) {
        self.goods = goods
        self.skuName = skuName
        self.skuPrice = skuPrice
        self.goodCommentsRate = goodCommentsRate
    }

    public static let csvHeader = Goods.csvHeader + ", skuName, skuPrice, goodCommentsRate"

    public var csvRow: String {
        goods.csvRow + ", \(skuName), \(skuPrice), \(goodCommentsRate)"
    }
}
