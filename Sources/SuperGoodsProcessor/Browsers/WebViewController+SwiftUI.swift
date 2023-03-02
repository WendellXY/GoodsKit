//
//  WebViewController+SwiftUI.swift
//  SuperGoodsProcessor
//
//  Created by Xinyu Wang on 2023/3/02
//  Copyright © 2023 Xinyu Wang. All rights reserved.
//
#if canImport(UIKit)
    import SwiftUI

    public struct SGPWebView: UIViewControllerRepresentable {
        public typealias UIViewControllerType = WebViewController

        public init() { }

        public func makeUIViewController(context: Context) -> WebViewController {
            WebViewController()
        }

        public func updateUIViewController(_ uiViewController: WebViewController, context: Context) {
            // nothing to do
        }
    }
#endif
