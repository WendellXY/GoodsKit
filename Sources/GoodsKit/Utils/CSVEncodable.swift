//
//  CSVEncodable.swift
//  GoodsProcessor
//
//  Created by Xinyu Wang on 2023/2/20
//  Copyright © 2023 Xinyu Wang. All rights reserved.
//

public protocol CSVEncodable {
    static var csvHeader: String { get }
    var csvRow: String { get }
}
