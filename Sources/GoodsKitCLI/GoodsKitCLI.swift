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

    @Flag(name: [.customLong("init")], help: "Initialize Basic Environment")
    var initialize = false

    @Flag(name: [.customLong("check")], help: "Check If Configuration is Valid")
    var checkConfig = false

    static func initializeEnvironment() throws {
        try FileManager.default.createDirectory(at: .configDirectory, withIntermediateDirectories: true, attributes: nil)

        // Create a sample configuration
        let sampleConfiguration = Configuration.sample

        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted

        let sampleConfigData = try jsonEncoder.encode(sampleConfiguration)

        // Save the configuration to a file
        try sampleConfigData.write(to: .configFileURL)
    }

    mutating func run() async throws {
        if initialize {
            try Self.initializeEnvironment()
        }

        if checkConfig {
            if try await PDDService.shared.isPidAuthorized() {
                print("Configuration is valid.")
            } else {
                print("Pid is not authorized.")
            }
        }
    }
}
