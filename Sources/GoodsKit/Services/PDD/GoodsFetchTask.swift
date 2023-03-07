//
//  GoodsFetchTask.swift
//  SuperGoodsProcessor
//
//  Created by Xinyu Wang on 2023/3/07
//  Copyright © 2023 Xinyu Wang. All rights reserved.
//

import Foundation

public struct GoodsFetchTask {

    // swiftlint:disable identifier_name
    public enum GoodsSortType: Int {
        case 综合排序 = 0
        case 按佣金比率升序 = 1
        case 按佣金比例降序 = 2
        case 按价格升序 = 3
        case 按价格降序 = 4
        case 按销量升序 = 5
        case 按销量降序 = 6
        case 优惠券金额排序升序 = 7
        case 优惠券金额排序降序 = 8
        case 券后价升序排序 = 9
        case 券后价降序排序 = 10
        case 按照加入多多进宝时间升序 = 11
        case 按照加入多多进宝时间降序 = 12
        case 按佣金金额升序排序 = 13
        case 按佣金金额降序排序 = 14
        case 店铺描述评分升序 = 15
        case 店铺描述评分降序 = 16
        case 店铺物流评分升序 = 17
        case 店铺物流评分降序 = 18
        case 店铺服务评分升序 = 19
        case 店铺服务评分降序 = 20
        case 描述评分击败同类店铺百分比升序 = 27
        case 描述评分击败同类店铺百分比降序 = 28
        case 物流评分击败同类店铺百分比升序 = 29
        case 物流评分击败同类店铺百分比降序 = 30
        case 服务评分击败同类店铺百分比升序 = 31
        case 服务评分击败同类店铺百分比降序 = 32
    }

    // swiftlint:enable identifier_name

    // MARK: - Shared Properties

    /// 商品关键词，与opt_id字段选填一个或全部填写。可支持goods_id、拼多多链接（即拼多多app商详的链接）、进宝长链/短链）
    public var keyword: String?
    /// 商品类目ID，使用pdd.goods.cats.get接口获取
    public var catId: Int?
    /// 商品标签类目ID，使用pdd.goods.opt.get获取
    public var optId: Int?
    /// 默认100，每页商品数量
    public var pageSize: Int = 100
    public var sortType: GoodsSortType?
    public var isBrandGoods: Bool?
    /// 是否使用个性化推荐，true表示使用，false表示不使用
    public var useCustomized: Bool?
    /// 是否只返回优惠券的商品，false返回所有商品，true只返回有优惠券的商品
    public var withCoupon: Bool?

    // MARK: - Fetch Single Page Goods
    /// 默认值1，商品分页数
    var page: Int = 1
    /// 翻页时建议填写前页返回的list_id值
    var listId: String?

    var queryItems: [URLQueryItem] {
        [
            URLQueryItem(key: "keyword", value: keyword),
            URLQueryItem(key: "cat_id", value: catId),
            URLQueryItem(key: "opt_id", value: optId),
            URLQueryItem(key: "page", value: page),
            URLQueryItem(key: "page_size", value: pageSize),
            URLQueryItem(key: "sort_type", value: sortType?.rawValue),
            URLQueryItem(key: "is_brand_goods", value: isBrandGoods?.description),
            URLQueryItem(key: "use_customized", value: useCustomized?.description),
            URLQueryItem(key: "with_coupon", value: withCoupon?.description),
            URLQueryItem(key: "list_id", value: listId),
        ].compactMap { $0 }
    }

    // MARK: - Fetch Goods List
    /// number of pages to fetch
    public var pageCount: Int = 1

    // MARK: - Initializers

    public init() {}

    public init(keyword: String, pageCount: Int) {
        self.keyword = keyword
        self.pageCount = pageCount
    }
}
