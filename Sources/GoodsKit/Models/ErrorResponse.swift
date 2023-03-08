//
//  ErrorResponse.swift
//  GoodsKit
//
//  Created by Xinyu Wang on 2023/2/24
//  Copyright © 2023 Xinyu Wang. All rights reserved.
//

import Foundation

public struct ErrorResponse: Codable {
    public let errorMsg: String?
    public let subMsg: String?
    public let subCode: Int?
    public let errorCode: Int?
    public let requestId: String
}
