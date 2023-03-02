//
//  GoodsCategory.swift
//  SuperGoodsProcessor
//
//  Created by Xinyu Wang on 2023/2/24
//  Copyright © 2023 Xinyu Wang. All rights reserved.
//

import Foundation

public struct GoodsCategory: Codable {
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

        do {
            let result = try decoder.decode([String: RawGoodsCategoryResponse].self, from: data)
            return result.values.first?.goodsCatsList.map { GoodsCategory(from: $0) } ?? []
        } catch DecodingError.keyNotFound {
            let result = try decoder.decode([String: ErrorResponse].self, from: data)
            throw APIError.errorResponse(result.values.first!)
        } catch {
            throw error
        }
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
    let requestId: String
}
