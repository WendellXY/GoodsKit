//
//  NSWebViewController.swift
//  SuperGoodsProcessor
//
//  Created by Xinyu Wang on 2023/3/02
//  Copyright © 2023 Xinyu Wang. All rights reserved.
//

#if os(macOS)

import AppKit
import WebKit

public final class NSWebViewController: NSViewController, SGPBrowserWrapper {

    public override func loadView() {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self

        self.view = webView
    }

    // swiftlint:disable:next force_cast
    public var webView: WKWebView { self.view as! WKWebView }

    public var goodsDataSet: Set<GoodsDetailData> = []
    public var noTagListURL: [URL] = []
    public var goodsID = 0

    public var kindIndex = 0
    public var itemIndex = 0

    public override func viewDidLoad() {
        super.viewDidLoad()
        startLoop()
    }
}

extension NSWebViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Task {
            do {
                try await parseFromWebView(webView)
            } catch {
                print(error)
            }
        }
    }
}

#endif
