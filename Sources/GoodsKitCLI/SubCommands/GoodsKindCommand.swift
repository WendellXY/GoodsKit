//
//  GoodsKindCommand.swift
//  GoodsKit
//
//  Created by Xinyu Wang on 2023/3/09
//  Copyright © 2023 Xinyu Wang. All rights reserved.
//

import ArgumentParser
import GoodsKit

enum GoodsKindType: String, ExpressibleByArgument {
    case cat
    case opt
}

struct GoodsKindCommand: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "kind",
        abstract: "Goods Kind (like catID & optID) Related Commands"
    )

    @Argument(help: "Type of Goods Kind to Fetch")
    var type: GoodsKindType

    @Argument(help: "Parent ID of Current Kind Node")
    var parentId: Int = 0

    func run() async throws {
        switch type {
        case .cat:
            let cats = try await PDDService.shared.fetchGoodsCategories(parentCatId: parentId)
            print(cats.map(\.description).joined(separator: "\n"))
        case .opt:
            let opts = try await PDDService.shared.fetchGoodsOpt(parentOptId: parentId)
            print(opts.map(\.description).joined(separator: "\n"))
        }
    }
}
