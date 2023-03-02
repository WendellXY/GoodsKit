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

        let nextButton = NSButton(title: "Next", target: nil, action: #selector(goNextObjc))
        let reloadButton = NSButton(title: "Reload", target: nil, action: #selector(reloadObjc))

        // swiftlint:disable:next force_cast
        public var webView: WKWebView { self.view as! WKWebView }

        public var goodsDataSet: Set<GoodsDetailData> = []
        public var noTagListURL: [URL] = []
        public var goodsID = 0

        public var kindIndex = 0
        public var itemIndex = 0

        public override func viewDidLoad() {
            super.viewDidLoad()

            view.addSubview(nextButton)
            view.addSubview(reloadButton)

            reloadButton.translateOrigin(to: .init(x: 100, y: 0))

            startLoop()
        }

        @objc private func goNextObjc() {
            self.goNext()
        }

        @objc private func reloadObjc() {
            self.reload()
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
