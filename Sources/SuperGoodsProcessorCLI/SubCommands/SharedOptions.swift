//
//  SharedOptions.swift
//  SuperGoodsProcessor
//
//  Created by Xinyu Wang on 2023/3/02
//  Copyright © 2023 Xinyu Wang. All rights reserved.
//

import ArgumentParser
import Foundation

struct SharedOptions: ParsableArguments {

    @Option(name: .long, help: "Custom Target Name")
    var target: String = "goods"

    @Option(name: .long, help: "Custom Output Name")
    var output: String = "goods"

    @Option(
        name: [.customLong("save")],
        help: "Custom Saving Path (default: ~/Documents/SuperGoodsProcessor/)")
    var savingDirectoryPath: String?

    var savingDirectoryURL: URL {
        guard let savingDirectoryPath else { return .defaultResultSavingDirectory }

        return URL(filePath: savingDirectoryPath, directoryHint: .isDirectory)
    }

    // Creates a directory at the specified URL if one does not already exist.
    // Throws an error if the directory cannot be created.
    func initialize() throws {
        try FileManager.default.createDirectory(at: savingDirectoryURL, withIntermediateDirectories: true, attributes: nil)
    }
}
