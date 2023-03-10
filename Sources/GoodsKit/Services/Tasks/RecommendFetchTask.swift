//
//  RecommendFetchTask.swift
//  GoodsKit
//
//  Created by Xinyu Wang on 2023/3/09
//  Copyright © 2023 Xinyu Wang. All rights reserved.
//

import Foundation

public struct RecommendFetchTask: PagedFetchTask {

    public static var type: GoodsResponseType = .recommend

    /// 商品类目ID，使用pdd.goods.cats.get接口获取
    public var catId: Int?
    /// 进宝频道推广商品类型
    public var channelType: ChannelType = .实时热销榜
    /// 请求获取相似商品时必传
    public var similarGoodsSign: String?
    /// 每页商品数量；默认值 ： 20
    public var pageSize: Int = 20

    /// 默认值1，商品分页数
    public var currentPage: Int = 1

    public var listId: String?

    public var queryItems: [URLQueryItem] {
        [
            URLQueryItem(key: "cat_id", value: catId),
            URLQueryItem(key: "channel_type", value: channelType.rawValue),
            URLQueryItem(key: "goods_sign_list", value: similarGoodsSign?.surrounded(with: "[", "]")),
            URLQueryItem(key: "limit", value: pageSize),
            URLQueryItem(key: "list_id", value: listId),
            URLQueryItem(key: "offset", value: (currentPage - 1) * pageSize),
        ].compactMap { $0 }
    }

    public var pageCount: Int = 1

    public init() {}
}

extension RecommendFetchTask {
    // swiftlint:disable identifier_name
    public enum ChannelType: Int {
        case 今日销量榜 = 1
        case 相似商品推荐 = 3
        case 猜你喜欢 = 4
        case 实时热销榜 = 5
        case 实时收益榜 = 6
    }
    // swiftlint:enable identifier_name
}
