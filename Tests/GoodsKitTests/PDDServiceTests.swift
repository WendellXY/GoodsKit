//
//  PDDServiceTests.swift
//  GoodsKit
//
//  Created by Xinyu Wang on 2023/2/24
//  Copyright © 2023 Xinyu Wang. All rights reserved.
//

import XCTest

@testable import GoodsKit

final class PDDServiceTests: XCTestCase {

    func testHTTPRequest() async throws {
        let request = URLRequest(url: URL(string: "https://www.apple.com")!)
        let data = try await PDDService.shared.performHTTPRequest(request)
        XCTAssertFalse(data.isEmpty)
    }

    func testFetchGoodsCategories() async throws {
        let categories = try await PDDService.shared.fetchGoodsCategories()
        XCTAssertFalse(categories.isEmpty)
    }

    func testFetchGoodsOpts() async throws {
        let opts = try await PDDService.shared.fetchGoodsOpt()
        XCTAssertFalse(opts.isEmpty)
    }

    @available(*, deprecated)
    func testFetchGoodsDeprecated() async throws {
        let goodsList = try await PDDService.shared.fetchGoodsList(keyword: "酸奶", pageCount: 1, sortType: 0)
        XCTAssertFalse(goodsList.isEmpty)

        let goods = try await PDDService.shared.fetchGoodsList(keyword: "酸奶", pageCount: 1, sortType: 1)
        XCTAssertFalse(goods.isEmpty)
    }

    func testFetchGoodsRecommend() async throws {
        var task = RecommendFetchTask()
        task.channelType = .实时收益榜
        task.pageCount = 1

        let goods = try await PDDService.shared.fetch(task)
        XCTAssertFalse(goods.isEmpty)
        XCTAssertEqual(goods.count, Set(goods).count)
    }

    func testFetchGoods() async throws {
        var task = GoodsFetchTask()
        task.keyword = "酸奶"
        task.pageCount = 2
        task.sortType = .综合排序
        let goods = try await PDDService.shared.fetch(task)
        XCTAssertFalse(goods.isEmpty)
        XCTAssertEqual(goods.count, Set(goods).count)
    }

    func testRegeneratePromotionURL() async throws {
        let promotionURL = try await PDDService.shared.regeneratePromotionURL(sourceURL: "https://p.pinduoduo.com/oCL2oHSF")

        XCTAssert(promotionURL.mobileShortUrl?.isEmpty == false)
        XCTAssert(promotionURL.mobileUrl?.isEmpty == false)
        XCTAssert(promotionURL.multiGroupMobileShortUrl?.isEmpty == false)
        XCTAssert(promotionURL.multiGroupMobileUrl?.isEmpty == false)
        XCTAssert(promotionURL.multiGroupShortUrl?.isEmpty == false)
        XCTAssert(promotionURL.multiGroupUrl?.isEmpty == false)
        XCTAssert(promotionURL.shortUrl?.isEmpty == false)
        XCTAssert(promotionURL.url?.isEmpty == false)
    }

    func testPidAuthority() async throws {
        do {
            let _ = try await PDDService.shared.isPidAuthorized()
        } catch {
            XCTFail()
        }
    }
}
