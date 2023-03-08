//
//  SGPBrowserWrapper.swift
//  GoodsKit
//
//  Created by Xinyu Wang on 2023/3/01
//  Copyright © 2023 Xinyu Wang. All rights reserved.
//

import WebKit

public protocol SGPBrowserWrapper: AnyObject {
    var webView: WKWebView { get }

    var goodsDataSet: Set<GoodsDetailData> { get set }
    var noTagListURL: [URL] { get }
    var goodsID: Int { get set }

    var kindIndex: Int { get set }
    var itemIndex: Int { get set }
}

// MARK: - Basic

extension SGPBrowserWrapper {
    public static var maxRepeatedTimes: Int { SGPBrowsersConfiguration.maxRepeatedTimes }

    public static var goodsKinds: [String] {
        get { SGPBrowsersConfiguration.goodsKinds }
        set { SGPBrowsersConfiguration.goodsKinds = newValue }
    }

    public static var goodsList: [[GoodsData]] {
        get { SGPBrowsersConfiguration.goodsList }
        set { SGPBrowsersConfiguration.goodsList = newValue }
    }

    // The currentURL property returns the URL of the current page of the web view.
    public var currentURL: URL? {
        webView.url
    }

    public var kind: String {
        Self.goodsKinds[kindIndex]
    }

    public var isInComments: Bool {
        currentURL?.absoluteString.contains("goods_comments") ?? false
    }

    func consolePrint(_ string: String) {
        let progress = Double(itemIndex + 1) / Double(Self.goodsList[kindIndex].count) * 100
        print("\(String(format: "[%0.2f%%]:\(goodsDataSet.count):\(goodsID): ", progress))\(string)")
    }
}

// MARK: - WebView Controls

extension SGPBrowserWrapper {
    /// Reloads the webview.
    func reload() {
        webView.reload()
    }

    func goNext() {
        itemIndex += 1

        if itemIndex == Self.goodsList[kindIndex].count {
            itemIndex = 0
            kindIndex += 1
            saveData()
        } else if itemIndex % 50 == 0 {
            saveData()
        }

        guard kindIndex < Self.goodsKinds.count else { return saveData() }

        consolePrint("=================================")

        let goodsData = Self.goodsList[kindIndex][itemIndex]
        goodsID = goodsData.id

        let request = URLRequest(url: goodsData.goodsDetails)
        webView.load(request)
    }

    // Saves the data set to a JSON file with the name "goods.data.json"
    func saveData() {
        do {
            let data = try JSONEncoder().encode(goodsDataSet)
            let docDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

            try data.write(to: docDirectory.appending(component: "goods.data.json"))
        } catch {
            print(error)
        }
    }

    func startLoop() {
        kindIndex = 0
        itemIndex = 0

        let goodsData = Self.goodsList[kindIndex][itemIndex]
        goodsID = goodsData.id
        let request = URLRequest(url: goodsData.goodsDetails)
        webView.load(request)
    }
}

// MARK: - WebView Parsing

extension SGPBrowserWrapper {

    func parseSKUList(
        from webView: WKWebView, skuList: inout [String: Double], nodeTableJS: String, skuCategoriesCount: Int
    ) async throws {
        func parseSKU(prefix prefixStr: String = "") async throws {
            guard let skuAmount = try await webView.evaluate("\(nodeTableJS)[\(skuCategoriesCount - 1)].length") as? Int else { return }

            for index in 0..<skuAmount {
                let node = "\(nodeTableJS)[\(skuCategoriesCount - 1)][\(index)]"

                try await webView.evaluate("\(node).click()")
                try await Task.sleep(nanoseconds: 500_000_000)

                let name = [
                    prefixStr,
                    try await webView.evaluate("\(node).innerText") as? String ?? "",
                ].filter(\.isEmpty.negated).joined(separator: " ")

                guard let priceNode = try await webView.evaluate("document.getElementsByClassName('_27FaiT3N')[0].innerHTML") as? String,
                    let price = priceNode.firstMatch(of: moneyPattern)?.output.1
                else { continue }

                skuList[name] = price

                try await webView.evaluate("\(node).click()")
            }
        }

        guard skuList.isEmpty else { return }

        consolePrint("Parsing SKUs")

        guard skuCategoriesCount > 1 else { return try await parseSKU() }

        // select one of the sku of the first category
        consolePrint("Found multiple levels of SKU")
        guard let firstCategoryLength = try await webView.evaluate("\(nodeTableJS)[0].length") as? Int else { return }

        for index in 0..<firstCategoryLength {
            consolePrint("Parsing category, loop \(index)")
            let node = "\(nodeTableJS)[0][\(index)]"
            let name = try await webView.evaluate("\(node).innerText") as? String ?? ""
            try await webView.evaluate("\(node).click()")
            try await Task.sleep(nanoseconds: 500_000_000)
            try await parseSKU(prefix: name)
        }
    }

    /// This function will parse comments tag from html
    ///
    /// - Parameters:
    ///   - webView: WKWebView to parse
    ///   - tagList: list of tags to parse
    ///   - isForceParse: is force parse
    ///   - counter: counter
    ///   - html: html to parse
    ///
    /// - Returns: parsed comments tag
    func parseCommentsTag(from webView: WKWebView, tagList: inout Set<GoodsCommentsTag>, isForceParse: Bool, counter: Int, html: String) async throws {
        guard tagList.isEmpty else { return }

        if isForceParse, let tagListHTML = try? await webView.evaluate("document.getElementsByClassName('e_o0GHaH')[0].innerHTML") as? String {
            consolePrint("Parsing Comments by forceParsing pattern")
            tagListHTML.matches(of: rawDataPatternForceParsing).map(\.output)
                .map { GoodsCommentsTag(name: $0.1, num: $0.2, positive: 1) }
                .forEach { tagList.insert($0) }
        } else if counter == 1, let data = html.firstMatch(of: rawDataPattern)?.output.1.data(using: .utf8) {
            consolePrint("Parsing Comments by default pattern")
            try JSONDecoder().decode([GoodsCommentsTag].self, from: data)
                .forEach { tagList.insert($0) }
        } else if let tagListHTML = try? await webView.evaluate("document.getElementsByClassName('_39zjdry7')[0].innerHTML") as? String {
            consolePrint("Parsing Comments by alternative pattern")
            tagListHTML.replacing(tagPrefixPattern, with: "")
                .matches(of: rawDataPatternAlternative).map(\.output)
                .map { GoodsCommentsTag(name: $0.1, num: $0.2, positive: 1) }
                .forEach { tagList.insert($0) }
        }
        consolePrint("DONE")
    }

    func parseFromWebView(_ webView: WKWebView, forceParse: Bool = false) async throws {
        var counter = 0

        guard isInComments || forceParse else {
            while !isInComments && counter < Self.maxRepeatedTimes * 3 {
                consolePrint("Entering Comments Page, loop \(counter)")
                counter += 1
                do {
                    try await Task.sleep(nanoseconds: 500_000_000)
                    try await webView.evaluate("document.getElementsByClassName('Xf3hkLsM')[0].click()")
                } catch {
                    continue
                }
            }

            if counter == Self.maxRepeatedTimes * 3 {
                consolePrint("Force Parsing Web Page")
                return try await parseFromWebView(webView, forceParse: currentURL?.absoluteString.contains("goods2.html") ?? false)
            }

            return
        }

        var skuList: [String: Double] = [:]
        var tagList: Set<GoodsCommentsTag> = []

        while counter < Self.maxRepeatedTimes && (tagList.isEmpty || skuList.isEmpty) {
            consolePrint("Parsing SKU & Comment Tag, loop \(counter)")
            counter += 1

            try await Task.sleep(nanoseconds: 1_000_000_000)
            try await webView.evaluate("document.getElementsByClassName('Qzax7E1w')[1].click()")
            try await Task.sleep(nanoseconds: 1_000_000_000)
            try await webView.evaluate("document.getElementsByClassName('_2bBCR7qt')[0] && document.getElementsByClassName('_2bBCR7qt')[0].click()")

            let nodeTable = """
                [...document.querySelectorAll('._1XqP0nf5')]
                    .map(element => [...element.querySelectorAll('._1WyUf92E')]
                    .filter(element => !element.classList.contains('PphFt0vU')))
                """

            guard let html = try await webView.evaluate("document.body.innerHTML") as? String else { continue }
            guard let skuCategoryAmount = try await webView.evaluate("\(nodeTable).length") as? Int else { continue }

            try await parseSKUList(from: webView, skuList: &skuList, nodeTableJS: nodeTable, skuCategoriesCount: skuCategoryAmount)
            try await parseCommentsTag(from: webView, tagList: &tagList, isForceParse: forceParse, counter: counter, html: html)
        }

        goodsDataSet.insert(GoodsDetailData(id: goodsID, tagList: Array(tagList), skuList: skuList))

        goNext()
    }
}
