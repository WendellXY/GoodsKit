//
//  WebPatterns.swift
//  GoodsKit
//
//  Created by Xinyu Wang on 2023/3/01
//  Copyright © 2023 Xinyu Wang. All rights reserved.
//

import RegexBuilder

let rawDataPattern = Regex {
    #/,"tags":/#
    Capture {
        OneOrMore(.any)
    }
    #/,"pageNumber"/#
}

let rawDataPatternAlternative = Regex {
    #/<li class="_2kK8WYHF.*?">/#
    Capture {
        OneOrMore(.word)
    } transform: { match in
        String(match)
    }
    "("
    TryCapture {
        OneOrMore(.digit)
    } transform: { match in
        Int(match)
    }
    ")"
    #/</li>/#
}

let rawDataPatternForceParsing = Regex {
    #/<div role="button" aria-label="/#
    Capture {
        OneOrMore(.word)
    } transform: { match in
        String(match)
    }
    "("
    TryCapture {
        OneOrMore(.digit)
    } transform: { match in
        Int(match)
    }
    ")"
    #/" class="_3ay9Dpz6 G067p65l">/#
}

let moneyPattern = Regex {
    "¥"
    TryCapture {
        OneOrMore(.digit)
        Optionally {
            "."
            OneOrMore(.digit)
        }
    } transform: { match in
        Double(match)
    }
}

let tagPrefixPattern = Regex {
    #/<span class="_1dYEWyUd.*?</span>/#
}
