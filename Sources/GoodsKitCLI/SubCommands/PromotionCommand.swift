//
//  PromotionCommand.swift
//  GoodsKit
//
//  Created by Xinyu Wang on 2023/3/02
//  Copyright © 2023 Xinyu Wang. All rights reserved.
//

import ArgumentParser
import GoodsKit

struct PromotionCommand: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "promotion",
        abstract: "Promotion Related Commands"
    )

    @Option(name: .shortAndLong, help: "Regenerate promotion link")
    var regenerateLink: String?

    func run() async throws {
        if let regenerateLink {
            let promotionURL = try await PDDService.shared.regeneratePromotionURL(sourceURL: regenerateLink)

            print(promotionURL)
        }
    }
}
