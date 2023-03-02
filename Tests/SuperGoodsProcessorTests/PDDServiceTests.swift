//
//  PDDServiceTests.swift
//  SuperGoodsProcessor
//
//  Created by Xinyu Wang on 2023/2/24
//  Copyright © 2023 Xinyu Wang. All rights reserved.
//

import XCTest

@testable import SuperGoodsProcessor

final class PDDServiceTests: XCTestCase {
    func testFetchGoodsCategories() async throws {
        let categories = try await PDDService.shared.fetchGoodsCategories()
        XCTAssertFalse(categories.isEmpty)
    }

    func testFetchGoods() async throws {
        let goods = try await PDDService.shared.fetchGoodsList(keyword: "酸奶", pageSize: 20)
        XCTAssertFalse(goods.isEmpty)
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
}
