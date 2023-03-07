//
//  GoodsOptTests.swift
//  SuperGoodsProcessor
//
//  Created by Xinyu Wang on 2023/3/03
//  Copyright © 2023 Xinyu Wang. All rights reserved.
//

import XCTest

@testable import SuperGoodsProcessor

final class GoodsOptTests: XCTestCase {
    func testGoodsOptDecode() throws {
        guard let url = Bundle.module.url(forResource: "goodsOpts", withExtension: "json") else { return }

        let data = try Data(contentsOf: url)
        let opts = try GoodsCategory.decodeOptsFrom(data)

        XCTAssertEqual(opts.count, 1)
    }

    func testGoodsOptDecodeError() throws {
        guard let url = Bundle.module.url(forResource: "errorResponse", withExtension: "json") else { return }

        let data = try Data(contentsOf: url)
        XCTAssertThrowsError(try GoodsCategory.decodeOptsFrom(data)) { error in
            guard case APIError.errorResponse(let response) = error else {
                return XCTFail("Wrong error type")
            }

            XCTAssert(response.errorMsg == "公共参数错误:type")
            XCTAssert(response.subMsg == "")
            XCTAssert(response.subCode == nil)
            XCTAssert(response.errorCode == 10001)
            XCTAssert(response.requestId == "15440104776643887")
        }

        XCTAssertThrowsError(try GoodsCategory.decodeOptsFrom(Data()))
    }

    func testGoodsOptsDesc() throws {
        guard let url = Bundle.module.url(forResource: "goodsOpts", withExtension: "json") else { return }

        let data = try Data(contentsOf: url)
        let opts = try GoodsCategory.decodeOptsFrom(data)

        XCTAssertEqual(opts.first!.description, "239-男装:[0:1]")
    }
}
