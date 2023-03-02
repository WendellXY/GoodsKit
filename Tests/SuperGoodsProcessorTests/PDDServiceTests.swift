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
        let goods = try await PDDService.shared.fetchGoods(keywords: "酸奶", pageSize: 20)
        XCTAssertFalse(goods.0.isEmpty)
    }
}
