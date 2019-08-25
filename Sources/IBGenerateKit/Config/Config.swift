//
//  Config.swift
//  IBGenerateKit
//
//  Created by phimage on 28/07/2019.
//

import Foundation
import Yams

public struct Config: Codable {
    public let excluded: [String]
    public let included: [String]
    public let color: Bool
    public let imports: [String]

    enum CodingKeys: String, CodingKey {
        case excluded
        case included
        case color
        case imports
    }

    public static let fileName = ".ibgenerate.yml"
    public static let `default` = Config.init()

    private init() {
        excluded = []
        included = []
        color = true
        imports = []
    }

    init(excluded: [String] = [], included: [String] = [], color: Bool = true, imports: [String] = []) {
        self.excluded = excluded
        self.included = included
        self.color = color
        self.imports = imports
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        excluded = try container.decodeIfPresent(Optional<[String]>.self, forKey: .excluded).flatMap { $0 } ?? []
        included = try container.decodeIfPresent(Optional<[String]>.self, forKey: .included).flatMap { $0 } ?? []
        color = try container.decodeIfPresent(Optional<Bool>.self, forKey: .color).flatMap { $0 } ?? true
        imports = try container.decodeIfPresent(Optional<[String]>.self, forKey: .imports).flatMap { $0 } ?? []
    }

    public init(url: URL) throws {
        self = try YAMLDecoder().decode(from: String.init(contentsOf: url))
    }

    public init(directoryURL: URL, fileName: String = fileName) throws {
        let url = directoryURL.appendingPathComponent(fileName)
        try self.init(url: url)
    }
}
