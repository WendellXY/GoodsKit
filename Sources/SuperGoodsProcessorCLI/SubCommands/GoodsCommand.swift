//
//  GoodsCommand.swift
//  SuperGoodsProcessor
//
//  Created by Xinyu Wang on 2023/3/02
//  Copyright © 2023 Xinyu Wang. All rights reserved.
//

import ArgumentParser
import Foundation
import SuperGoodsProcessor

extension SuperGoodsProcessorCLI {
    struct GoodsCommand: AsyncParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "goods",
            abstract: "Goods Related Commands"
        )

        @Argument(help: "Keyword to Search")
        var keyword: String?

        @Option(name: [.customLong("cat")], help: "Category ID of Goods to Fetch")
        var catId: Int?

        @Option(name: [.customLong("opt")], help: "Option ID of Goods to Fetch")
        var optId: Int?

        @Option(name: [.short, .long], help: "Number of Goods Pages to Fetch")
        var pages: Int = 10

        @Option(name: [.customLong("size"), .long], help: "Number of Goods Per Page to Fetch")
        var pageSize: Int = 100

        @Option(name: [.customLong("sort"), .long], help: "Sorting Type of Goods to Fetch")
        var sortType: Int?

        @OptionGroup var options: SharedOptions

        func fetchGoods() async throws {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted

            var goodsTask = GoodsFetchTask()
            goodsTask.keyword = keyword
            goodsTask.catId = catId
            goodsTask.optId = optId
            goodsTask.pageCount = pages
            goodsTask.pageSize = pageSize

            if let sortType {
                goodsTask.sortType = GoodsFetchTask.GoodsSortType(rawValue: sortType)
            }

            let goods = try await PDDService.shared.fetch(goodsTask)

            // Raw Data
            let rawData = try encoder.encode(goods.map(\.toData))
            try rawData.write(to: options.savingDirectoryURL.appending(component: "\(options.output).raw.json"))

            // Detailed JSON
            let data = try encoder.encode(goods)
            try data.write(to: options.savingDirectoryURL.appending(component: "\(options.output).json"))

            // TO CSV
            var csv = Goods.csvHeader + "\n"
            csv.append(contentsOf: goods.map(\.csvRow).joined(separator: "\n"))
            try csv.write(to: options.savingDirectoryURL.appending(component: "\(options.output).csv"), atomically: true, encoding: .utf8)
        }

        func run() async throws {
            try options.initialize()

            try await fetchGoods()
        }
    }
}
