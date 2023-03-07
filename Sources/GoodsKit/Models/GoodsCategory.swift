//
//  GoodsCategory.swift
//  GoodsKit
//
//  Created by Xinyu Wang on 2023/2/24
//  Copyright © 2023 Xinyu Wang. All rights reserved.
//

import Foundation

public struct GoodsCategory: Codable, CustomStringConvertible {
    public let name: String
    public let level: Int
    public let id: Int
    public let parentId: Int

    private init(from rawData: RawGoodsCategoryResponse.GoodsCategory) {
        self.name = rawData.catName
        self.level = rawData.level
        self.id = rawData.catId
        self.parentId = rawData.parentCatId
    }

    public static func decodeCategoriesFrom(_ data: Data) throws -> [GoodsCategory] {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        var categories: [GoodsCategory] = []

        do {
            let result = try decoder.decodeFirstProperty(RawGoodsCategoryResponse.self, from: data)
            categories = result.goodsCatsList.map { GoodsCategory(from: $0) }
        } catch DecodingError.keyNotFound {
            let result = try decoder.decodeFirstProperty(ErrorResponse.self, from: data)
            throw APIError.errorResponse(result)
        } catch {
            throw error
        }

        return categories
    }

    public var description: String {
        "\(id)-\(name):[\(parentId):\(level)]"
    }
}

private struct RawGoodsCategoryResponse: Codable {
    struct GoodsCategory: Codable {
        let catName: String
        let level: Int
        let catId: Int
        let parentCatId: Int
    }
    let goodsCatsList: [GoodsCategory]
    let requestId: String?
}
