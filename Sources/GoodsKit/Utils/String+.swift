//
//  String+.swift
//  GoodsKit
//
//  Created by Xinyu Wang on 2023/3/07
//  Copyright © 2023 Xinyu Wang. All rights reserved.
//

extension String {

    /// Surrounds the string with the given string
    ///
    /// - Parameters:
    ///   - str1: The string to be surrounded with
    ///   - str2: The string to be surrounded with. If nil, `str1` will be used
    ///
    /// - Returns: The surrounded string
    func surrounded(with str1: String, _ str2: String? = nil) -> String {
        guard !str1.isEmpty else { return self }
        return str1 + self + (str2 ?? str1)
    }

    /// Prepends the string with the given string
    func prepending(_ string: String) -> String {
        guard !string.isEmpty else { return self }
        return string + self
    }
}
