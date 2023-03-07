//
//  GoodsKitCLI.swift
//  GoodsKit
//
//  Created by Xinyu Wang on 2023/3/02
//  Copyright © 2023 Xinyu Wang. All rights reserved.
//

import ArgumentParser
import Foundation
import GoodsKit

@main
struct GoodsKitCLI: AsyncParsableCommand {
    private(set) var text = "Hello, Super Goods Processor!"

    static var configuration = CommandConfiguration(
        abstract: "Super Goods Processor CLI",
        version: "0.0.1",
        subcommands: [
            GoodsCommand.self,
            GoodsDetailsCommand.self,
            PromotionCommand.self,
        ]
    )

    @Flag(name: [.customLong("init"), .short], help: "Initialize Basic Environment")
    var initialize = false

    init() {
        guard let data = try? Data(contentsOf: .defaultResultSavingDirectory.appendingPathComponent("config.json")) else { return }
        if let config = try? JSONDecoder().decode(Configuration.self, from: data) {
            PDDService.shared.config = config
        }
    }

    static func initializeEnvironment() throws {
        try FileManager.default.createDirectory(at: .defaultResultSavingDirectory, withIntermediateDirectories: true, attributes: nil)

        // Create a sample configuration
        let sampleConfiguration = Configuration.sample

        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted

        let sampleConfigData = try jsonEncoder.encode(sampleConfiguration)

        // Save the configuration to a file
        try sampleConfigData.write(to: .defaultResultSavingDirectory.appendingPathComponent("config.json"))
    }

    mutating func run() async throws {
        if initialize {
            try Self.initializeEnvironment()
        }
    }
}
