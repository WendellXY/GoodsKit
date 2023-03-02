//
//  Goods.swift
//  SuperGoodsProcessor
//
//  Created by Xinyu Wang on 2023/2/24
//  Copyright © 2023 Xinyu Wang. All rights reserved.
//

import Foundation

public struct Goods: Codable, CSVEncodable {

    public let id: Int

    public let price: Double

    public let brandName: String?

    public let categoryName: String
    public let categoryId: [Int]

    public let coupon: Coupon

    public let name: String
    public let sign: String
    public let desc: String

    public let hasCoupon: Bool

    public let mallName: String

    public let mallEvaluation: MallGeneralEvaluation

    public let promotionRate: Double

    public let salesAmount: Int

    public var goodsDetailURL: URL {
        URL(string: "https://jinbao.pinduoduo.com/goods-detail?s=\(sign)")!
    }

    public var goodsProductURL: URL {
        URL(string: "https://mobile.yangkeduo.com/goods2.html?goods_id=\(id)&uin=BCA6GC5C3IJW7XRFI5DN5JI7TA_GEXDA")!
    }

    public static let csvHeader: String = "id, price, brand, category, discount, name, sign, mallName, promotionRate, salesAmount"
    public var csvRow: String {
        let items = [
            "\(id)", "\(price)", brandName ?? "", categoryName, "\(coupon.discount)", name.replacing(",", with: " "),
            sign, mallName, "\(promotionRate)", "\(salesAmount)"
        ]

        return items.joined(separator: ",")
    }

    private init(from rawData: RawGoodsSearchResponse.Goods) {
        self.id = rawData.goodsId
        self.price = Double(min(rawData.minNormalPrice, rawData.minGroupPrice)) / 100
        self.brandName = rawData.brandName
        self.categoryName = rawData.categoryName
        self.categoryId = rawData.catIds
        self.coupon = Coupon(
            discount: rawData.couponDiscount / 100,
            startTime: Date(timeIntervalSince1970: TimeInterval(rawData.couponStartTime)),
            endTime: Date(timeIntervalSince1970: TimeInterval(rawData.couponEndTime)),
            minOrderAmount: rawData.couponMinOrderAmount,
            remainQuantity: rawData.couponRemainQuantity,
            totalQuantity: rawData.couponTotalQuantity
        )
        self.name = rawData.goodsName
        self.sign = rawData.goodsSign
        self.desc = rawData.goodsDesc
        self.hasCoupon = rawData.hasCoupon
        self.mallName = rawData.mallName
        self.mallEvaluation = MallGeneralEvaluation(rawData.lgstTxt, rawData.servTxt, rawData.descTxt)
        self.promotionRate = Double(rawData.promotionRate) / 1000

        let salesTip = rawData.salesTip
        if salesTip.hasSuffix("+") {
            self.salesAmount = 100000
        } else if salesTip.hasSuffix("万") {
            self.salesAmount = Int((Double(salesTip.dropLast()) ?? 0) * 10000)
        } else {
            self.salesAmount = Int(salesTip) ?? -1
        }
    }

    public static func decodeGoodsFrom(_ data: Data) throws -> ([Goods], String) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        do {
            let result = try decoder.decode([String: RawGoodsSearchResponse].self, from: data)
            let response = result.values.first!
            return (response.goodsList.map { Goods(from: $0) }, response.listId)
        } catch DecodingError.keyNotFound {
            let result = try decoder.decode([String: ErrorResponse].self, from: data)
            throw APIError.errorResponse(result.values.first!)
        } catch {
            throw error
        }
    }

    public var toData: GoodsData {
        GoodsData(id: id, goodsDetails: goodsProductURL)
    }
}

private struct RawGoodsSearchResponse: Codable {

    struct Goods: Codable {
        /// 活动佣金比例，千分比（特定活动期间的佣金比例）
        let activityPromotionRate: Int?
        /// 商品活动标记数组，例：[4,7]，4-秒杀 7-百亿补贴等
        let activityTags: [Int]
        /// 活动类型，0-无活动;1-秒杀;3-限量折扣;12-限时折扣;13-大促活动;14-名品折扣;15-品牌清仓;16-食品超市;17-一元幸运团;18-爱逛街;19-时尚穿搭;20-男人帮;21-9块9;22-竞价活动;23-榜
        /// 单活动;24-幸运半价购;25-定金预售;26-幸运人气购;27-特色主题活动;28-断码清仓;29-一元话费;30-电器城;31-每日好店;32-品牌卡;101-大促搜索池;102-大促品类分会场;
        let activityType: Int?
        /// 商品品牌词信息，如“苹果”、“阿迪达斯”、“李宁”等
        let brandName: String?
        /// 全局礼金金额，单位分
        let cashGiftAmount: Int?
        /// 商品类目名称
        let categoryName: String
        /// 商品类目id
        let catIds: [Int]
        /// 店铺收藏券id
        let cltCpnBatchSn: String?
        /// 店铺收藏券面额,单位为分
        let cltCpnDiscount: Int?
        /// 店铺收藏券截止时间
        let cltCpnEndTime: Int?
        /// 店铺收藏券使用门槛价格,单位为分
        let cltCpnMinAmt: Int?
        /// 店铺收藏券总量
        let cltCpnQuantity: Int?
        /// 店铺收藏券剩余量
        let cltCpnRemainQuantity: Int?
        /// 店铺收藏券起始时间
        let cltCpnStartTime: Int?
        /// 优惠券面额，单位为分
        let couponDiscount: Int
        /// 优惠券失效时间，UNIX时间戳
        let couponEndTime: Int
        /// 优惠券门槛价格，单位为分
        let couponMinOrderAmount: Int
        /// 优惠券剩余数量
        let couponRemainQuantity: Int
        /// 优惠券生效时间，UNIX时间戳
        let couponStartTime: Int
        /// 优惠券总数量
        let couponTotalQuantity: Int
        /// 创建时间（unix时间戳）
        let createAt: Int?
        /// 描述分
        let descTxt: String
        /// 额外优惠券，单位为分
        let extraCouponAmount: Int?
        let goodsId: Int
        /// 商品描述
        let goodsDesc: String
        /// 商品主图
        let goodsImageUrl: String
        /// 商品特殊标签列表。例: [1]，1-APP专享
        let goodsLabels: [Int]?
        /// 商品名称
        let goodsName: String
        /// 商品goodsSign，支持通过goodsSign查询商品。goodsSign是加密后的goodsId, goodsId已下线，请使用goodsSign来替代。
        /// 使用说明：https://jinbao.pinduoduo.com/qa-system?questionId=252
        let goodsSign: String
        /// 商品缩略图
        let goodsThumbnailUrl: String
        /// 商品是否有优惠券 true-有，false-没有
        let hasCoupon: Bool
        /// 是否有店铺券
        let hasMallCoupon: Bool
        /// 商品是否有素材(图文、视频)
        let hasMaterial: Bool
        /// 物流分
        let lgstTxt: String
        /// 店铺券折扣
        let mallCouponDiscountPct: Int
        /// 店铺券结束使用时间
        let mallCouponEndTime: Int
        /// 店铺券id
        let mallCouponId: Int?
        /// 最大使用金额
        let mallCouponMaxDiscountAmount: Int
        /// 最小使用金额
        let mallCouponMinOrderAmount: Int
        /// 店铺券余量
        let mallCouponRemainQuantity: Int
        /// 店铺券开始使用时间
        let mallCouponStartTime: Int
        /// 店铺券总量
        let mallCouponTotalQuantity: Int
        /// 该商品所在店铺是否参与全店推广，0：否，1：是
        let mallCps: Int
        /// 店铺id
        let mallId: Int
        /// 店铺名字
        let mallName: String
        /// 店铺类型，1-个人，2-企业，3-旗舰店，4-专卖店，5-专营店，6-普通店
        let merchantType: Int
        /// 最小拼团价（单位为分）
        let minGroupPrice: Int
        /// 最小单买价格（单位为分）
        let minNormalPrice: Int
        /// 快手专享
        let onlySceneAuth: Bool
        /// 商品标签ID，使用pdd.goods.opts.get接口获取
        let optId: Int
        /// 商品标签id
        let optIds: [Int]
        /// 商品标签名
        let optName: String
        /// 推广计划类型: 1-全店推广 2-单品推广 3-定向推广 4-招商推广 5-分销推广
        let planType: Int
        /// 比价行为预判定佣金，需要用户备案
        let predictPromotionRate: Int
        /// 佣金比例，千分比
        let promotionRate: Int
        /// 已售卖件数
        let salesTip: String
        /// 搜索id，建议生成推广链接时候填写，提高收益
        let searchId: String
        /// 服务分
        let servTxt: String
        /// 服务标签: 1-全场包邮,2-七天退换,3-退货包运费,4-送货入户并安装,5-送货入户,6-电子发票,7-诚信发货,8-缺重包赔,9-坏果包赔,10-果重保证,11-闪电退款,12-24小时发货,13-48小时发货,
        /// 14-免税费,15-假一罚十,16-贴心服务,17-顺丰包邮,18-只换不修,19-全国联保,20-分期付款,21-纸质发票,22-上门安装,23-爱心助农,24-极速退款,25-品质保障,26-缺重包退,27-当日发货,
        /// 28-可定制化,29-预约配送,30-商品进口,31-电器城,1000001-正品发票,1000002-送货入户并安装,2000001-价格保护
        let serviceTags: [Int]
        /// 招商分成服务费比例，千分比
        let shareRate: Int
        /// 优势渠道专属商品补贴金额，单位为分。针对优质渠道的补贴活动，指定优势渠道可通过推广该商品获取相应补贴。补贴活动入口：[进宝网站-官方活动]
        let subsidyAmount: Int?
        /// 官方活动给渠道的收入补贴金额，不允许直接给下级代理展示，单位为分
        let subsidyDuoAmountTenMillion: Int?
        /// 优惠标签列表，包括："X元券","比全网低X元","服务费","精选素材","近30天低价","同款低价","同款好评","同款热销","旗舰店","一降到底","招商优选","商家优选","好价再降X元","全站销量XX","实时热销榜第X名","实时好评榜第X名","额外补X元"等
        let unifiedTags: [String?]
        /// 招商团长id
        let zsDuoId: Int
    }

    let goodsList: [Goods]
    let listId: String
    let searchId: String
    let totalCount: Int
}
