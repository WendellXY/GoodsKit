//
//  WebKit+.swift
//  GoodsKit
//
//  Created by Xinyu Wang on 2023/3/01
//  Copyright © 2023 Xinyu Wang. All rights reserved.
//

import WebKit

extension WKWebView {
    /// Evaluates javascript asynchronously and returns the output
    @discardableResult func evaluate(_ javascript: String) async throws -> Any {
        // Use a continuation to execute the javascript and await the result
        try await withCheckedThrowingContinuation { continuation in
            // Evaluate the javascript
            evaluateJavaScript(javascript, in: nil, in: .page) { result in
                // Handle the result
                switch result {
                case .success(let output):
                    continuation.resume(returning: output)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
