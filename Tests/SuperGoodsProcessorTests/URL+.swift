//
//  URL+.swift
//  SuperGoodsProcessor
//
//  Created by Xinyu Wang on 2023/3/03
//  Copyright © 2023 Xinyu Wang. All rights reserved.
//

import Foundation

extension URL {
    /// Returns true if the URL is reachable, false otherwise.
    func isReachable() async throws -> Bool {
        var request = URLRequest(url: self)
        request.httpMethod = "HEAD"
        let (_, response) = try await URLSession.shared.data(for: request)
        return (response as? HTTPURLResponse)?.statusCode == 200
    }
}
