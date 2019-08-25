//
//  VersionCommand.swift
//  IBGenerateFrontend
//
//  Created by phimage on 28/07/2019.
//

import Result
import Commandant

struct VersionCommand: CommandProtocol {
    let verb = "version"
    let function = "Display the current version of IBGenerate"

    func run(_ options: NoOptions<CommandantError<()>>) -> Result<(), CommandantError<()>> {
        print(Version.current.value)
        return .success(())
    }
}
