//
//  GoodsOpt.swift
//  SuperGoodsProcessor
//
//  Created by Xinyu Wang on 2023/3/03
//  Copyright © 2023 Xinyu Wang. All rights reserved.
//

import Foundation

public typealias GoodsOpt = GoodsCategory

extension GoodsOpt {
    private init(from rawData: RawGoodsOptResponse.GoodsOpt) {
        self.name = rawData.optName
        self.level = rawData.level
        self.id = rawData.optId
        self.parentId = rawData.parentOptId
    }

    public static func decodeOptsFrom(_ data: Data) throws -> [GoodsOpt] {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        var opts: [GoodsOpt] = []

        do {
            let result = try decoder.decode([String: RawGoodsOptResponse].self, from: data)
            opts = result.values.first?.goodsOptList.map { GoodsOpt(from: $0) } ?? []
        } catch DecodingError.keyNotFound {
            let result = try decoder.decode([String: ErrorResponse].self, from: data)
            throw APIError.errorResponse(result.values.first!)
        } catch {
            throw error
        }

        return opts
    }
}

private struct RawGoodsOptResponse: Codable {
    struct GoodsOpt: Codable {
        let optName: String
        let level: Int
        let optId: Int
        let parentOptId: Int
    }
    let goodsOptList: [GoodsOpt]
    let requestId: String?
}
