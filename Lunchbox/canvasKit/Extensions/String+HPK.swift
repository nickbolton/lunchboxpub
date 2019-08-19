//
//  String+HPK.swift
//  LunchboxCanvasKit
//
//  Created by Nick Bolton on 1/10/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import Foundation

public extension String {    
    var properIdentifier: String {
        var result = replacingOccurrences(of: " +", with: " ", options: .regularExpression)
        let components = result.split(separator: " ").map { String($0).properName }
        result = components.joined()
        result = result.replacingOccurrences(of: "[^_a-zA-Z0-9]", with: "", options: .regularExpression)
        if result.count <= 0 {
            return "_"
        }
        if let range = result.range(of: "[0-9]", options: .regularExpression, range: nil, locale: nil), range.lowerBound == result.startIndex {
            result = "_" + result
        }
        if result.count <= 1 {
            return result.lowercased(with: Locale.current)
        }
        let second = result.index(result.startIndex, offsetBy: 1)
        var secondAndOn = String(result.suffix(from: second))
        let maxSize = 29
        if secondAndOn.count > maxSize {
            let maxIndex = secondAndOn.index(secondAndOn.startIndex, offsetBy: maxSize)
            secondAndOn = String(secondAndOn[secondAndOn.startIndex..<maxIndex])
        }
        return String(result.prefix(upTo: second)).lowercased(with: Locale.current) + secondAndOn
    }
    
    var properName: String {
        let result = replacingOccurrences(of: "\\s", with: "", options: .regularExpression)
        if result.count <= 1 {
            return result.lowercased(with: Locale.current)
        }
        let second = result.index(result.startIndex, offsetBy: 1)
        return String(result.prefix(upTo: second)).uppercased(with: Locale.current) + String(result.suffix(from: second))
    }
    
    static func stringType(of some: Any) -> String {
        let string = (some is Any.Type) ? String(describing: some) : String(describing: type(of: some))
        return string
    }
}
