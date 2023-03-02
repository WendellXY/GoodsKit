//
//  SuperGoodsProcessorCLI.swift
//  SuperGoodsProcessor
//
//  Created by Xinyu Wang on 2023/3/02
//  Copyright © 2023 Xinyu Wang. All rights reserved.
//

import SuperGoodsProcessor
import ArgumentParser
import Foundation

@main
struct SuperGoodsProcessorCLI: AsyncParsableCommand {
    private(set) var text = "Hello, Super Goods Processor!"

    @Flag(name: .shortAndLong, help: "Fetch goods from PDD")
    var fetchGoods: Bool = false

    @Flag(name: .shortAndLong, help: "Process goods details")
    var processGoodsDetails: Bool = false

    func fetchGoods(optId: Int, pages: Int) async throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        let goods = try await PDDService.shared.fetchGoodsList(optId: optId, pageCount: pages)

        // Raw Data
        let rawData = try encoder.encode(goods.map(\.toData))
        try rawData.write(to: .playgroundResourceDirectory.appending(component: "goods.raw.json"))

        // Detailed JSON
        let data = try encoder.encode(goods)
        try data.write(to: .playgroundResourceDirectory.appending(component: "goods.json"))
        print(goods.count)

        // TO CSV
        var csv = Goods.csvHeader + "\n"
        csv.append(contentsOf: goods.map(\.csvRow).joined(separator: "\n"))
        try csv.write(to: .playgroundResourceDirectory.appending(component: "goods.csv"), atomically: true, encoding: .utf8)
    }

    func processGoodsDetails() async throws {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        // Load Good Details
        var goodsDetailsMap: [Int: GoodsDetailData] = [:]

        let detailsData = try Data(contentsOf: .desktopDirectory.appending(component: "goodsData.json"))
        try decoder.decode([GoodsDetailData].self, from: detailsData).forEach { details in
            goodsDetailsMap[details.id] = details
        }

        // Load Goods List
        let goodsData = try Data(contentsOf: .desktopDirectory.appending(component: "goods.json"))
        let goods = try decoder.decode([Goods].self, from: goodsData)

        let result = goods.compactMap { goods in
            goodsDetailsMap[goods.id]?.skuList.map { sku in
                GoodsShowcase(goods: goods, skuName: sku.key, skuPrice: sku.value, goodCommentsRate: goodsDetailsMap[goods.id]?.goodCommentsRate ?? -1)
            }
        }.reduce(GoodsShowcase.csvHeader) { $0 + "\n" + $1.map(\.csvRow).joined(separator: "\n") }

        try result.write(to: .playgroundResourceDirectory.appending(component: "goods.csv"), atomically: true, encoding: .utf8)
    }

    mutating func run() async throws {
        print(SuperGoodsProcessorCLI().text)

        do {
            if fetchGoods {
                try await fetchGoods(optId: 1, pages: 10)
            }

            if processGoodsDetails {
                try await processGoodsDetails()
            }

        } catch {
            print(error)
        }
    }
}
