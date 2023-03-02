//
//  WebViewController.swift
//  SuperGoodsProcessor
//
//  Created by Xinyu Wang on 2023/3/01
//  Copyright © 2023 Xinyu Wang. All rights reserved.
//

#if canImport(UIKit)

    import Foundation
    import UIKit
    import WebKit
    import RegexBuilder

    public class WebViewController: UIViewController, SGPBrowserWrapper {

        public static var goodsKinds: [String] = []
        public static var goodsList: [[GoodsData]] = []

        public override func loadView() {
            let config = WKWebViewConfiguration()
            let webView = WKWebView(frame: .zero, configuration: config)
            webView.navigationDelegate = self

            self.view = webView
        }

        let nextButton = UIButton(type: .infoDark)
        let reloadButton = UIButton(type: .contactAdd)

        // swiftlint:disable:next force_cast
        public var webView: WKWebView { self.view as! WKWebView }

        public var goodsDataSet: Set<GoodsDetailData> = []
        public var noTagListURL: [URL] = []
        public var goodsID = 0

        public var kindIndex = 0
        public var itemIndex = 0

        public override func viewDidLoad() {
            super.viewDidLoad()

            nextButton.addAction(
                .init(handler: { _ in
                    self.goNext()
                }), for: .touchUpInside)

            reloadButton.addAction(
                .init(handler: { _ in
                    self.reload()
                }), for: .touchUpInside)

            view.addSubview(nextButton)
            view.addSubview(reloadButton)

            reloadButton.transform = .init(translationX: 100, y: 0)

            startLoop()
        }
    }

    extension WebViewController: WKNavigationDelegate {
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
