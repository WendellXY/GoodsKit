//
//  JSONDecoder+.swift
//  GoodsKit
//
//  Created by Xinyu Wang on 2023/3/03
//  Copyright © 2023 Xinyu Wang. All rights reserved.
//

import Foundation

extension JSONDecoder {

    /// Decodes the first property of a JSON object into a type conforming to Decodable.
    func decodeFirstProperty<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable {
        // swiftlint:disable:next force_cast
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let firstProperty = json.first!.value
        let firstPropertyData = try JSONSerialization.data(withJSONObject: firstProperty)
        return try decode(type, from: firstPropertyData)
    }
}
