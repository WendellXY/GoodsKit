//
//  GoodsDetailsCommand.swift
//  SuperGoodsProcessor
//
//  Created by Xinyu Wang on 2023/3/02
//  Copyright © 2023 Xinyu Wang. All rights reserved.
//

import ArgumentParser
import Foundation
import SuperGoodsProcessor

extension SuperGoodsProcessorCLI {
    struct GoodsDetailsCommand: AsyncParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "details",
            abstract: "Goods Details Related Commands"
        )

        @Flag(name: [.short, .customLong("process-details")], help: "Process goods details")
        var processGoodsDetails: Bool = false

        @OptionGroup(title: "IO Options")
         var options: SharedOptions

        func processGoodsDetails() async throws {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            // Load Good Details
            var goodsDetailsMap: [Int: GoodsDetailData] = [:]

            let detailsData = try Data(contentsOf: options.savingDirectoryURL.appending(component: "\(options.target).data.json"))
            try decoder.decode([GoodsDetailData].self, from: detailsData).forEach { details in
                goodsDetailsMap[details.id] = details
            }

            // Load Goods List
            let goodsData = try Data(contentsOf: options.savingDirectoryURL.appending(component: "\(options.target).json"))
            let goods = try decoder.decode([Goods].self, from: goodsData)

            let result = goods.compactMap { goods in
                goodsDetailsMap[goods.id]?.skuList.map { sku in
                    GoodsShowcase(goods: goods, skuName: sku.key, skuPrice: sku.value, goodCommentsRate: goodsDetailsMap[goods.id]?.goodCommentsRate ?? -1)
                }
            }.reduce(GoodsShowcase.csvHeader) { $0 + "\n" + $1.map(\.csvRow).joined(separator: "\n") }

            try result.write(to: options.savingDirectoryURL.appending(component: "\(options.output).csv"), atomically: true, encoding: .utf8)
        }

        func run() async throws {
            try options.initialize()

            if processGoodsDetails {
                try await processGoodsDetails()
            }
        }
    }
}
