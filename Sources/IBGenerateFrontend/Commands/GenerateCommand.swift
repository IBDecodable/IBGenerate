//
//  GenerateCommand.swift
//  IBGenerateFrontend
//
//  Created by phimage on 28/07/2019.
//

import Result
import Foundation
import IBDecodable
import IBGenerateKit
import Commandant
import PathKit

struct GenerateCommand: CommandProtocol {
    typealias Options = GenerateOptions
    typealias ClientError = Options.ClientError

    let verb: String = "generate"
    var function: String = "Generate code (default command)"

    func run(_ options: GenerateCommand.Options) -> Result<(), GenerateCommand.ClientError> {
        let workDirectoryString = options.path ?? FileManager.default.currentDirectoryPath
        let workDirectory = URL(fileURLWithPath: workDirectoryString)
        guard FileManager.default.isDirectory(workDirectory.path) else {
            fatalError("\(workDirectoryString) is not directory.")
        }

        let config = Config(options: options) ?? Config.default
        let codeBuilder = CodeBuilder()
        let code = codeBuilder.code(workDirectory: workDirectory, config: config)

        print(code)

        if code.isEmpty {
            exit(2)
        } else {
            return .success(())
        }
    }
}

struct GenerateOptions: OptionsProtocol {
    typealias ClientError = CommandantError<()>

    let path: String?
    let configurationFile: String?

    static func create(_ path: String?) -> (_ config: String?) -> GenerateOptions {
        return { config in
            self.init(path: path, configurationFile: config)
        }
    }

    static func evaluate(_ mode: CommandMode) -> Result<GenerateCommand.Options, CommandantError<GenerateOptions.ClientError>> {
        return create
            <*> mode <| Option(key: "path", defaultValue: nil, usage: "validate project root directory")
            <*> mode <| Option(key: "config", defaultValue: nil, usage: "the path to IBGenerate's configuration file")
    }
}

extension Config {
    init?(options: GenerateOptions) {
        if let configurationFile = options.configurationFile {
            let configurationURL = URL(fileURLWithPath: configurationFile)
            try? self.init(url: configurationURL)
        } else {
            let workDirectoryString = options.path ?? FileManager.default.currentDirectoryPath
            let workDirectory = URL(fileURLWithPath: workDirectoryString)
            try? self.init(directoryURL: workDirectory)
        }
    }
}
