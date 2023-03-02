//
//  APIError.swift
//  SuperGoodsProcessor
//
//  Created by Xinyu Wang on 2023/2/24
//  Copyright © 2023 Xinyu Wang. All rights reserved.
//

public enum APIError: Error {
    case httpStatusCode(Int)
    case errorResponse(ErrorResponse)
}
