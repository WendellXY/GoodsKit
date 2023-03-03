//
//  SuperGoodsProcessorCLI.swift
//  SuperGoodsProcessor
//
//  Created by Xinyu Wang on 2023/3/02
//  Copyright © 2023 Xinyu Wang. All rights reserved.
//

import ArgumentParser
import Foundation
import SuperGoodsProcessor

@main
struct SuperGoodsProcessorCLI: AsyncParsableCommand {
    private(set) var text = "Hello, Super Goods Processor!"

    static var configuration = CommandConfiguration(
        abstract: "Super Goods Processor CLI",
        version: "0.0.1",
        subcommands: [
            GoodsCommand.self,
            GoodsDetailsCommand.self,
            PromotionCommand.self,
        ],
        defaultSubcommand: GoodsCommand.self
    )
}
