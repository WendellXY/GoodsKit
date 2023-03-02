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

    @Option(name: .shortAndLong, help: "Custom Target Name")
    var target: String = "goods"

    @Option(name: .shortAndLong, help: "Custom Output Name")
    var output: String = "goods"

    @Option(name: .short, help: "Custom Saving Path, Default to ~/Documents/SuperGoodsProcessor/")
    var savingDirectoryPath: String?

    @Flag(name: .customLong("save-to-playground"), help: "Save Result to Playground Resources")
    var saveToPlaygroundResource: Bool = false

    var savingDirectoryURL: URL {
        guard !saveToPlaygroundResource else { return .playgroundResourceDirectory }

        guard let savingDirectoryPath else { return .defaultResultSavingDirectory }

        return URL(filePath: savingDirectoryPath, directoryHint: .isDirectory)
    }
}
