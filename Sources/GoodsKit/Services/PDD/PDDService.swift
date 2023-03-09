//
//  PDDService.swift
//  GoodsKit
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

    public var session: URLSession = .shared

    public var config = Configuration.shared

    private init() {}

    private let baseURL = URL(string: "https://gw-api.pinduoduo.com/api/router")!

    private var name: String {
        String(describing: Self.self)
    }
}

extension PDDService {

    private func checkConfiguration() {
        guard !config.clientID.isEmpty else {
            fatalError("\(name): clientID is not set")
        }

        guard !config.clientSecret.isEmpty else {
            fatalError("\(name): clientSecret is not set")
        }

        guard !config.pid.isEmpty else {
            fatalError("\(name): pid is not set")
        }
    }

    /// Downloads data from the given URL
    /// Returns the data if the download succeeds, otherwise throws an error
    public func performHTTPRequest(_ request: URLRequest) async throws -> Data {
        let (data, response) = try await session.data(for: request)

        // Check for HTTP errors
        if let response = response as? HTTPURLResponse, let status = response.status {
            switch status.responseType {
            case .success: break
            default: throw status
            }
        }

        // Return the data
        return data
    }

    /// Make a request to the API
    /// - Parameters:
    ///   - type: the type of request.
    ///   - queryItems: the query items for the request.
    ///   - contents: a function that returns an array of URL Query Items
    /// - Returns: a URLRequest
    private func makeAPIRequest(type: String, queryItems items: [URLQueryItem] = [], @URLQueryBuilder _ contents: () -> [URLQueryItem]) -> URLRequest {
        checkConfiguration()
        let queryItems = sharedQueryItems(for: type) + items + contents()
        let signedQuery = addSign(to: queryItems)
        return URLRequest(url: baseURL.appending(queryItems: signedQuery))
    }

    /// Returns the query items for a request to the API.
    ///
    /// - Parameters:
    ///   - type: The type of request.
    ///
    /// - Returns: The query items for the request.
    @URLQueryBuilder
    private func sharedQueryItems(for type: String) -> [URLQueryItem] {
        URLQueryItem(key: "type", value: type)
        URLQueryItem(key: "client_id", value: config.clientID)
        URLQueryItem(key: "timestamp", value: Int(Date.now.timeIntervalSince1970))
    }

    /// A helper function for adding a sign to a query string
    private func addSign(to queryItems: [URLQueryItem]) -> [URLQueryItem] {
        func makeSign(_ queryItems: [URLQueryItem]) -> String {
            let parameterStr = queryItems.sorted { itemA, itemB in
                itemA.name < itemB.name
            }.reduce("") { partialResult, item in
                partialResult + item.name + (item.value ?? "")
            }

            return MD5("\(config.clientSecret)\(parameterStr)\(config.clientSecret)").uppercased()
        }

        // Make the sign
        let sign = makeSign(queryItems)
        return queryItems + [URLQueryItem(name: "sign", value: sign)]
    }
}

// MARK: - Authority API

extension PDDService {

    private struct PidAuthorityResponse: Decodable {
        let bind: Int
        let requestId: String?
    }

    /// This function is used in the Pinduoduo API class and is used to check if a pid is authorized.
    public func isPidAuthorized() async throws -> Bool {
        let request = makeAPIRequest(type: "pdd.ddk.member.authority.query") {
            URLQueryItem(key: "pid", value: config.pid)
        }

        let data = try await performHTTPRequest(request)

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let response = try decoder.decodeFirstProperty(PidAuthorityResponse.self, from: data)

        return response.bind == 1
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

        let data = try await performHTTPRequest(request)

        return try GoodsCategory.decodeCategoriesFrom(data)
    }

    public func fetchGoodsOpt(parentOptId: Int = 0) async throws -> [GoodsOpt] {
        let request = makeAPIRequest(type: "pdd.goods.opt.get") {
            URLQueryItem(key: "parent_opt_id", value: parentOptId)
        }

        let data = try await performHTTPRequest(request)

        return try GoodsOpt.decodeOptsFrom(data)
    }

    /// Fetches a list of goods from the server.
    ///
    /// The list can be filtered by keyword, category, and/or option. The list is paginated. This method requests a single page of the list from the server. If
    /// you are request multiple pages, use ``fetchGoodsList`` instead. For details, check
    ///  [Official Document](https://open.pinduoduo.com/application/document/api?id=pdd.ddk.goods.search)
    ///
    /// - Parameters:
    ///   - keywords: Keywords to filter the list by.
    ///   - listId: The ID of the list, used for pagination.
    ///   - catId: Category ID to filter the list by.
    ///   - optId: Option ID to filter the list by.
    ///   - page: The page number to request.
    ///   - pageSize: The number of goods to request per page.
    ///   - sortType: The type of sorting to use.
    ///
    /// - Returns: A list of goods from the server.
    @available(*, deprecated, message: "Use fetch(_:) instead")
    private func fetchGoods(
        keywords: String? = nil, listId: String? = nil,
        catId: Int? = nil, optId: Int? = nil,
        page: Int = 1, pageSize: Int = 100,
        sortType: Int? = nil
    ) async throws -> ([Goods], String) {

        let request = makeAPIRequest(type: "pdd.ddk.goods.search") {
            URLQueryItem(key: "custom_parameters", value: #"{"new":1}"#)
            URLQueryItem(key: "pid", value: config.pid)
            URLQueryItem(key: "keyword", value: keywords)
            URLQueryItem(key: "cat_id", value: catId)
            URLQueryItem(key: "opt_id", value: optId)
            URLQueryItem(key: "page", value: page)
            URLQueryItem(key: "page_size", value: pageSize)
            URLQueryItem(key: "sort_type", value: sortType)
            URLQueryItem(key: "list_id", value: listId)
        }

        let data = try await performHTTPRequest(request)

        return try Goods.decode(responseType: .search, from: data)
    }

    private func _fetch(_ task: GoodsFetchTask) async throws -> ([Goods], String) {
        let request = makeAPIRequest(type: "pdd.ddk.goods.search", queryItems: task.queryItems) {
            URLQueryItem(key: "custom_parameters", value: #"{"new":1}"#)
            URLQueryItem(key: "pid", value: config.pid)
        }

        let data = try await performHTTPRequest(request)

        return try Goods.decode(responseType: .search, from: data)
    }

    public func fetch(_ task: GoodsFetchTask) async throws -> [Goods] {

        func printProgress(_ page: Int) {
            print("\r[\(page)/\(task.pageCount)] Fetching Goods List", terminator: "")
            fflush(__stdoutp)
        }

        printProgress(0)
        let startTime = Date.now

        defer {
            print(String(format: "\nFetch Completed! (%.2fs)", startTime.distance(to: Date.now)))
        }

        let pageCount = task.page

        guard pageCount > 0 else { return [] }

        var goods: [Goods] = []
        var task = task

        for pageIndex in 1...task.pageCount {
            printProgress(pageIndex)
            do {
                task.page = pageIndex
                let (pageGoods, newListId) = try await _fetch(task)
                goods.append(contentsOf: pageGoods)
                task.listId = newListId
            } catch {
                print("\nError: \(error)")
                break
            }
        }

        return goods
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
    ///   - sortType: The type of sorting to use.
    ///
    /// - Returns: A list of goods from the server.
    @available(*, deprecated, message: "Use fetch(_:) instead")
    public func fetchGoodsList(
        keyword: String? = nil, catId: Int? = nil, optId: Int? = nil,
        pageCount: Int = 10, pageSize: Int = 100,
        sortType: Int? = nil
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

        var (allGoods, listId) = try await fetchGoods(keywords: keyword, catId: catId, optId: optId, page: 1, pageSize: pageSize, sortType: sortType)
        printProgress(1)
        if pageCount == 1 {
            return allGoods
        }

        // fetch the rest of the pages, if any
        // Here we use a do-catch block to catch any errors that occur while fetching the goods, to avoid data loss.
        for page in 2...pageCount {
            guard
                let (newGoods, newListId) = try? await fetchGoods(
                    listId: listId, catId: catId, optId: optId, page: page, pageSize: pageSize, sortType: sortType)
            else { break }
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
            URLQueryItem(key: "pid", value: config.pid)
            URLQueryItem(key: "source_url", value: sourceURL)
        }

        let data = try await performHTTPRequest(request)

        return try PromotionURL.decodeFrom(data)
    }
}
