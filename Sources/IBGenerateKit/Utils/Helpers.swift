//
//  Helpers.swift
//  IBGenerateKit
//
//  Created by phimage on 25/08/2019.
//

import Foundation

enum FirstLetterFormat {
    case none
    case capitalize
    case lowercase
    
    func format(_ str: String) -> String {
        switch self {
        case .none:
            return str
        case .capitalize:
            return String(str.uppercased().unicodeScalars.prefix(1) + str.unicodeScalars.suffix(str.unicodeScalars.count - 1))
        case .lowercase:
            return String(str.lowercased().unicodeScalars.prefix(1) + str.unicodeScalars.suffix(str.unicodeScalars.count - 1))
        }
    }
}

func swiftRepresentation(for string: String, firstLetter: FirstLetterFormat = .none, doNotShadow: String? = nil) -> String {
    var str = string.trimAllWhitespacesAndSpecialCharacters()
    str = firstLetter.format(str)
    if str == doNotShadow {
        str += "_"
    }
    return str
}

func initIdentifier(for identifierString: String, value: String) -> String {
    if identifierString == "String" {
        return "\"\(value)\""
    } else {
        return "\(identifierString)(\"\(value)\")"
    }
}

extension String {
    func trimAllWhitespacesAndSpecialCharacters() -> String {
        let invalidCharacters = NSCharacterSet.alphanumerics.inverted
        let x = self.components(separatedBy: invalidCharacters)
        return x.joined(separator: "")
    }
}
