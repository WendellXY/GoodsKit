//
//  GoodsCategoryTests.swift
//  GoodsKit
//
//  Created by Xinyu Wang on 2023/3/03
//  Copyright © 2023 Xinyu Wang. All rights reserved.
//

import XCTest

@testable import GoodsKit

final class GoodsCategoryTests: XCTestCase {
    func testGoodsCategoriesDecode() throws {
        guard let url = Bundle.module.url(forResource: "goodsCategories", withExtension: "json") else { return }

        let data = try Data(contentsOf: url)
        let categories = try GoodsCategory.decodeCategoriesFrom(data)

        XCTAssertEqual(categories.count, 1)
    }

    func testGoodsCategoryDecodeError() throws {
        guard let url = Bundle.module.url(forResource: "errorResponse", withExtension: "json") else { return }

        let data = try Data(contentsOf: url)
        XCTAssertThrowsError(try GoodsCategory.decodeCategoriesFrom(data)) { error in
            guard case APIError.errorResponse(let response) = error else {
                return XCTFail("Wrong error type")
            }

            XCTAssert(response.errorMsg == "公共参数错误:type")
            XCTAssert(response.subMsg == "")
            XCTAssert(response.subCode == nil)
            XCTAssert(response.errorCode == 10001)
            XCTAssert(response.requestId == "15440104776643887")
        }

        XCTAssertThrowsError(try GoodsCategory.decodeCategoriesFrom(Data()))
    }

    func testGoodsCategoriesDesc() throws {
        guard let url = Bundle.module.url(forResource: "goodsCategories", withExtension: "json") else { return }

        let data = try Data(contentsOf: url)
        let categories = try GoodsCategory.decodeCategoriesFrom(data)

        XCTAssertEqual(categories.first!.description, "239-男装:[0:1]")
    }
}
