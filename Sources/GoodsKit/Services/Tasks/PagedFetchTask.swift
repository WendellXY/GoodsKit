//
//  PagedFetchTask.swift
//  GoodsKit
//
//  Created by Xinyu Wang on 2023/3/09
//  Copyright © 2023 Xinyu Wang. All rights reserved.
//

import Foundation

public protocol PagedFetchTask {
    var currentPage: Int { get set }
    var listId: String? { get set }
    /// number of pages to fetch
    var pageCount: Int { get }

    /// The corresponding API type
    static var type: GoodsResponseType { get }

    var queryItems: [URLQueryItem] { get }
}

extension PagedFetchTask {
    public var type: GoodsResponseType { Self.type }
}
