//
//  Xcode.swift
//  CYaml
//
//  Created by phimage on 25/08/2019.
//

import Foundation
import XcodeProjKit

public class Xcode {

    public static func get(projectFilePath: String? = nil, targetName: String? = nil, workDirectory: URL) -> Set<URL> {
        var urls = Set<URL>()
        let processInfo = ProcessInfo.processInfo
        let environment = processInfo.environment
        guard let projectFilePath = projectFilePath ?? environment["PROJECT_FILE_PATH"] else {
            print("No project file")
            return urls
        }
        guard let targetName = targetName ?? environment["TARGET_NAME"] else {
            print("No target to look up")
            return urls
        }

        let projectFileUrl = URL(fileURLWithPath: projectFilePath)
        guard let projectFile = try? XcodeProj(url: projectFileUrl) else {
            print("Failed to parse project file \(projectFilePath)")
            return urls
        }

        let targets = projectFile.project.targets
        guard let target = (targets.filter { $0.name == targetName}).first else {
            print("Target \(targetName) not found)")
            return urls
        }
        let files: [PBXFileReference] = target.buildPhases.flatMap { $0.files }.compactMap { $0.fileRef as? PBXFileReference }

        let urlBuilder: (SourceTreeFolder) -> URL = { sourceTreeFolder -> URL in
            if let envValue = environment[sourceTreeFolder.rawValue] {
                return URL(fileURLWithPath: envValue)
            }
            return workDirectory // fallback to workDirectory
        }

        for file in files {
            if let path = file.path, path.hasSuffix(".storyboard") {
                if let fullPath = file.fullPath(projectFile) {
                    let url = fullPath.url(with: urlBuilder)
                    urls.insert(url)
                } // else if name?
            }
        }
        return urls
    }
}
