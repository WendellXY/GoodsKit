// This is from the Xcode Playground, you can copy it to the playground and run it.

import Foundation
import GoodsKit
import PlaygroundSupport
import SwiftUI

struct ContentView: View {
    var body: some View {
        SGPWebView()
            .frame(width: 500, height: 500)
    }
}

// Set your own configuration, otherwise, it may crash
PDDService.shared.config = Configuration.load(from: .documentsDirectory.appending(component: "GoodsKit/.config/config.json"))

var goodTask = GoodsFetchTask()

goodTask.keyword = "酸奶"
goodTask.catId = 1

Task {
    SGPBrowsersConfiguration.goodsList.append(try await PDDService.shared.fetch(goodTask).map(\.toData))

    print(SGPBrowsersConfiguration.goodsList.map(\.count))

    await MainActor.run {
        PlaygroundPage.current.setLiveView(ContentView())
    }
}
