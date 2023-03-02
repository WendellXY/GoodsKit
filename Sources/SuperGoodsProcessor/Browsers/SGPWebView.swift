//
//  WebViewController+SwiftUI.swift
//  SuperGoodsProcessor
//
//  Created by Xinyu Wang on 2023/3/02
//  Copyright © 2023 Xinyu Wang. All rights reserved.
//

import SwiftUI
import WebKit

#if os(iOS)
typealias WebViewControllerRepresentable = UIViewControllerRepresentable
#elseif os(macOS)
typealias WebViewControllerRepresentable = NSViewControllerRepresentable
#endif

public struct SGPWebView: WebViewControllerRepresentable {
    public init() {}

    #if os(iOS)
    public typealias UIViewControllerType = UIWebViewController

    public func makeUIViewController(context: Context) -> UIWebViewController {
        UIWebViewController()
    }

    public func updateUIViewController(_ uiViewController: UIWebViewController, context: Context) {
        // nothing to do
    }
    #endif

    #if os(macOS)
    public typealias NSViewControllerType = NSWebViewController

    public func makeNSViewController(context: Context) -> NSWebViewController {
        NSWebViewController()
    }

    public func updateNSViewController(_ nsViewController: NSWebViewController, context: Context) {

    }
    #endif
}
