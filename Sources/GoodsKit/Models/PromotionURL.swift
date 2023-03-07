//
//  PromotionURL.swift
//  GoodsKit
//
//  Created by Xinyu Wang on 2023/3/02
//  Copyright © 2023 Xinyu Wang. All rights reserved.
//

import Foundation

public struct PromotionURL: Codable, CustomStringConvertible {
    /// 推广短链接（可唤起拼多多app）
    public let mobileShortUrl: String?
    /// 推广长链接（唤起拼多多app）
    public let mobileUrl: String?
    /// 推广短链接（唤起拼多多app）
    public let multiGroupMobileShortUrl: String?
    /// 推广长链接（可唤起拼多多app）
    public let multiGroupMobileUrl: String?
    /// 双人团推广短链接
    public let multiGroupShortUrl: String?
    /// 双人团推广长链接
    public let multiGroupUrl: String?
    /// 对应出参url的短链接，与url功能一致。
    public let shortUrl: String?
    /// 普通推广长链接，唤起H5页面
    public let url: String?

    public static func decodeFrom(_ data: Data) throws -> PromotionURL {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        var promotionURL: PromotionURL

        do {
            promotionURL = try decoder.decodeFirstProperty(PromotionURL.self, from: data)
        } catch DecodingError.keyNotFound {
            let result = try decoder.decodeFirstProperty(ErrorResponse.self, from: data)
            throw APIError.errorResponse(result)
        } catch {
            throw error
        }

        return promotionURL
    }

    public var description: String {
        let values = Mirror(reflecting: self).children.compactMap { (label, value) -> (String, String)? in
            guard let label, let value = value as? String else { return nil }
            return (label, value)
        }.reduce("") {
            $0 + "\($1.0): \($1.1)\n"
        }

        return """
            [PromotionURLs]: =====================
            \(values)

            """
    }
}
