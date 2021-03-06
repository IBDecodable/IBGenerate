//
//  Validator.swift
//  IBGenerateKit
//
//  Created by phimage on 28/07/2019.
//

import Foundation
import IBDecodable

public class CodeBuilder {

    public init() {}

    public func code(workDirectory: URL, config: Config) -> String {
        let files: Set<URL>
        if config.xcodeTarget {
            files = Xcode.get(workDirectory: workDirectory)
        } else {
            files = lintablePaths(workDirectory: workDirectory, config: config)
        }
        return code(files: files, config: config)
    }

    public func code(files: Set<URL>, config: Config) -> String {
        return files.compactMap { path in
            return try? StoryboardFile(path: path.relativePath)
            }.code(config: config)
    }

    private struct InterfaceBuilderFiles {
        var storyboardPaths: Set<URL> = []
    }

    private final class LintableFileMatcher {
        let fileManager: FileManager
        let globber: Glob
        init(fileManager: FileManager = .default) {
            self.fileManager = fileManager
            self.globber = Glob(fileManager: fileManager)
        }

        func interfaceBuilderFiles(withPatterns patterns: [URL]) -> InterfaceBuilderFiles {
            return patterns.flatMap { globber.expandRecursiveStars(pattern: $0.path) }
                .reduce(into: InterfaceBuilderFiles()) { result, path in
                    let files = self.interfaceBuilderFiles(atPath: URL(fileURLWithPath: path))
                    result.storyboardPaths.formUnion(files.storyboardPaths)
            }
        }

        func interfaceBuilderFiles(atPath path: URL) -> InterfaceBuilderFiles {
            var storyboards: Set<URL> = []
            guard let enumerator = fileManager.enumerator(at: path, includingPropertiesForKeys: [.isRegularFileKey]) else {
                return InterfaceBuilderFiles(storyboardPaths: storyboards)
            }

            for element in enumerator {
                guard let absolute = element as? URL else { continue }
                switch absolute.pathExtension {
                case "storyboard": storyboards.insert(absolute)
                default: continue
                }
            }
            return InterfaceBuilderFiles(storyboardPaths: storyboards)
        }
    }

    public func lintablePaths(workDirectory: URL, config: Config, fileManager: FileManager = .default) -> Set<URL> {
        let matcher = LintableFileMatcher(fileManager: fileManager)
        let files: InterfaceBuilderFiles
        if config.included.isEmpty {
            files = matcher.interfaceBuilderFiles(atPath: workDirectory)
        } else {
            files = matcher.interfaceBuilderFiles(
                withPatterns: config.included.map { workDirectory.appendingPathComponent($0) }
            )
        }

        let excluded = matcher.interfaceBuilderFiles(
            withPatterns: config.excluded.map { workDirectory.appendingPathComponent($0) }
        )
        let storyboardLintablePaths = files.storyboardPaths.subtracting(excluded.storyboardPaths)
        return storyboardLintablePaths
    }
}

extension Array where Element == StoryboardFile {
    func code(config: Config) -> String {
        return Natalie.process(storyboards: self, config: config)
    }
}
