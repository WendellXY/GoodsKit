//
//  GoodsTests.swift
//  SuperGoodsProcessor
//
//  Created by Xinyu Wang on 2023/3/03
//  Copyright © 2023 Xinyu Wang. All rights reserved.
//

import XCTest

@testable import SuperGoodsProcessor

final class GoodsTests: XCTestCase {

    override func setUp() async throws {
        try await super.setUp()

        let goodsList = try await PDDService.shared.fetch(GoodsFetchTask(keyword: "酸奶", pageCount: 1))
        goods = goodsList.first
    }

    var goods: Goods!

    func testGoodsURLs() async throws {
        let isGoodsDetailURLReachable = try await goods.goodsDetailURL.isReachable()
        XCTAssert(isGoodsDetailURLReachable)

        let isGoodsProductURLReachable = try await goods.goodsProductURL.isReachable()
        XCTAssert(isGoodsProductURLReachable)
    }

    func testGoodsCSV() throws {
        let header = Goods.csvHeader.split(separator: ",")
        let row = goods.csvRow.split(separator: ",")

        XCTAssert(header.count == row.count)
    }

    func testToData() throws {
        let data = goods.toData

        XCTAssertEqual(data.id, goods.id)
        XCTAssertEqual(data.goodsDetails, goods.goodsProductURL)
    }

    func testGoodsDecode() throws {
        guard let url = Bundle.module.url(forResource: "goods", withExtension: "json") else { return }

        let data = try Data(contentsOf: url)
        let goods = try Goods.decodeGoodsFrom(data)

        XCTAssertNotEqual(goods.0.count, 0)
    }

    func testGoodsDecodeError() throws {
        guard let url = Bundle.module.url(forResource: "errorResponse", withExtension: "json") else { return }

        let data = try Data(contentsOf: url)
        XCTAssertThrowsError(try Goods.decodeGoodsFrom(data)) { error in
            guard case APIError.errorResponse(let response) = error else {
                return XCTFail("Wrong error type")
            }

            XCTAssert(response.errorMsg == "公共参数错误:type")
            XCTAssert(response.subMsg == "")
            XCTAssert(response.subCode == nil)
            XCTAssert(response.errorCode == 10001)
            XCTAssert(response.requestId == "15440104776643887")
        }

        XCTAssertThrowsError(try Goods.decodeGoodsFrom(Data()))
    }

}
