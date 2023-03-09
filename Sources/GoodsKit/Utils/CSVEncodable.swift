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

extension String {
    var csvEncoded: String {
        var result = self

        result.removeAll(where: \.isNewline)

        if self.contains(",") {
            return "\"\(self)\""
        }

        return result
    }
}

extension Sequence where Element: CSVEncodable {
    public var csv: String {
        var csv = Element.csvHeader.csvEncoded + "\n"
        for element in self {
            csv += element.csvRow.csvEncoded + "\n"
        }
        return csv
    }
}
