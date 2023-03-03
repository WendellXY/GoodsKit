//
//  PDDService.swift
//  SuperGoodsProcessor
//
//  Created by Xinyu Wang on 2023/2/24
//  Copyright © 2023 Xinyu Wang. All rights reserved.
//

import Foundation

@resultBuilder
struct URLQueryBuilder {
    static func buildBlock(_ components: URLQueryItem?...) -> [URLQueryItem] {
        components.compactMap { $0 }
    }
}

public final class PDDService {
    /// The shared instance of the PDDService.
    public static let shared = PDDService()

    private init() {}

    private let config = Configuration.shared

    private let baseURL = URL(string: "https://gw-api.pinduoduo.com/api/router")!
}

extension PDDService {
    /// Make a request to the API
    /// - Parameters:
    ///   - type: the type of request.
    ///   - contents: a function that returns an array of URL Query Items
    /// - Returns: a URLRequest
    private func makeAPIRequest(type: String, @URLQueryBuilder _ contents: () -> [URLQueryItem]) -> URLRequest {
        let queryItems = Self.sharedQueryItems(for: type) + contents()
        let signedQuery = Self.addSign(to: queryItems)
        return URLRequest(url: baseURL.appending(queryItems: signedQuery))
    }

    /// Returns the query items for a request to the API.
    ///
    /// - Parameters:
    ///   - type: The type of request.
    ///
    /// - Returns: The query items for the request.
    @URLQueryBuilder
    private static func sharedQueryItems(for type: String) -> [URLQueryItem] {
        URLQueryItem(key: "type", value: type)
        URLQueryItem(key: "client_id", value: Configuration.shared.clientID)
        URLQueryItem(key: "timestamp", value: Int(Date.now.timeIntervalSince1970))
    }

    /// A helper function for adding a sign to a query string
    private static func addSign(to queryItems: [URLQueryItem]) -> [URLQueryItem] {
        func makeSign(_ queryItems: [URLQueryItem]) -> String {
            let parameterStr = queryItems.sorted { itemA, itemB in
                itemA.name < itemB.name
            }.reduce("") { partialResult, item in
                partialResult + item.name + (item.value ?? "")
            }

            return MD5("\(Configuration.shared.clientSecret)\(parameterStr)\(Configuration.shared.clientSecret)").uppercased()
        }

        // Make the sign
        let sign = makeSign(queryItems)
        return queryItems + [URLQueryItem(name: "sign", value: sign)]
    }
}

// MARK: - Goods API

extension PDDService {
    // This function is used to fetch a list of categories from the Pinduoduo API.
    // The `parentCatId` parameter is used to specify the parent category ID.
    public func fetchGoodsCategories(parentCatId: Int = 0) async throws -> [GoodsCategory] {
        let request = makeAPIRequest(type: "pdd.goods.cats.get") {
            URLQueryItem(key: "parent_cat_id", value: parentCatId)
        }
        let (data, _) = try await URLSession.shared.data(for: request)
        return try GoodsCategory.decodeCategoriesFrom(data)
    }

    public func fetchGoodsOpt(parentOptId: Int = 0) async throws -> [GoodsOpt] {
        let request = makeAPIRequest(type: "pdd.goods.opt.get") {
            URLQueryItem(key: "parent_opt_id", value: parentOptId)
        }
        let (data, _) = try await URLSession.shared.data(for: request)
        return try GoodsOpt.decodeOptsFrom(data)
    }

    /// Fetches a list of goods from the server.
    ///
    /// The list can be filtered by keyword, category, and/or option. The list is paginated. This method requests a single page of the list from the server. If
    /// you are request multiple pages, use ``fetchGoodsList`` instead.
    ///
    /// - Parameters:
    ///   - keywords: Keywords to filter the list by.
    ///   - listId: The ID of the list, used for pagination.
    ///   - catId: Category ID to filter the list by.
    ///   - optId: Option ID to filter the list by.
    ///   - page: The page number to request.
    ///   - pageSize: The number of goods to request per page.
    ///
    /// - Returns: A list of goods from the server.
    private func fetchGoods(
        keywords: String? = nil, listId: String? = nil,
        catId: Int? = nil, optId: Int? = nil,
        page: Int = 1, pageSize: Int = 100
    ) async throws -> ([Goods], String) {

        let request = makeAPIRequest(type: "pdd.ddk.goods.search") {
            URLQueryItem(key: "custom_parameters", value: #"{"new":1}"#)
            URLQueryItem(key: "pid", value: config.pid)
            URLQueryItem(key: "page", value: page)
            URLQueryItem(key: "page_size", value: pageSize)
            URLQueryItem(key: "keyword", value: keywords)
            URLQueryItem(key: "cat_id", value: catId)
            URLQueryItem(key: "opt_id", value: optId)
            URLQueryItem(key: "list_id", value: listId)
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        if let response = response as? HTTPURLResponse, response.statusCode != 200 {
            throw APIError.httpStatusCode(response.statusCode)
        }

        return try Goods.decodeGoodsFrom(data)
    }

    /// Fetches multiple pages of goods from the server.
    ///
    /// The list can be filtered by keyword, category, and/or option. The list is paginated. This method requests all pages of the list from the server, and
    /// returns a single array containing all the goods from all the pages.
    ///
    /// - Parameters:
    ///   - keyword: Keywords to filter the list by.
    ///   - catId: Category ID to filter the list by.
    ///   - optId: Option ID to filter the list by.
    ///   - page: The page number to request.
    ///   - pageSize: The number of goods to request per page.
    /// - Returns: A list of goods from the server.
    public func fetchGoodsList(
        keyword: String? = nil, catId: Int? = nil, optId: Int? = nil,
        pageCount: Int = 10, pageSize: Int = 100
    ) async throws -> [Goods] {

        func printProgress(_ page: Int) {
            print("\r[\(page)/\(pageCount)] Fetching Goods List", terminator: "")
            fflush(__stdoutp)
        }

        let startTime = Date.now

        printProgress(0)

        defer {
            print(String(format: "\nFetch Completed! (%.2fs)", startTime.distance(to: Date.now)))
        }

        var (allGoods, listId) = try await fetchGoods(keywords: keyword, catId: catId, optId: optId, page: 1, pageSize: pageSize)
        printProgress(1)
        if pageCount == 1 {
            return allGoods
        }

        // fetch the rest of the pages, if any
        // Here we use a do-catch block to catch any errors that occur while fetching the goods, to avoid data loss.
        for page in 2...pageCount {
            guard let (newGoods, newListId) = try? await fetchGoods(listId: listId, catId: catId, optId: optId, page: page, pageSize: pageSize) else { break }
            printProgress(page)

            allGoods.append(contentsOf: newGoods)
            listId = newListId
        }

        return allGoods
    }
}

// MARK: - Promotion

extension PDDService {
    // This function generates a promotion URL for a given source URL.
    //
    // - Parameters:
    //   - sourceURL: The source URL to generate a promotion URL for.
    // - Returns: The promotion URL.
    public func regeneratePromotionURL(sourceURL: String) async throws -> PromotionURL {
        // create request
        let request = makeAPIRequest(type: "pdd.ddk.goods.zs.unit.url.gen") {
            // URLQueryItem(key: "custom_parameters", value: #"{"new":1}"#)
            URLQueryItem(key: "pid", value: config.pid)
            URLQueryItem(key: "source_url", value: sourceURL)
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        // check response
        if let response = response as? HTTPURLResponse, response.statusCode != 200 {
            throw APIError.httpStatusCode(response.statusCode)
        }

        return try PromotionURL.decodeFrom(data)
    }
}
