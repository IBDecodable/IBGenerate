//
//  Compat.swift
//  IBGenerateKit
//
//  Created by phimage on 25/08/2019.
//

import Foundation
import IBDecodable

extension StoryboardDocument {
    var os: OS {
        return targetRuntime.os
    }

    var colors: [Color] {
        return self.children(of: Color.self, recursive: true)
    }

    var customModules: Set<String> {
        return Set((self.scenes ?? []).filter { $0.customModule != nil && $0.customModuleProvider == nil }.map { $0.customModule! })
    }

    var initialViewControllerClass: String? {
        guard let id = self.initialViewController else {
            return nil
        }
        if let vc = self.searchById(id: id) {
            // The initialViewController class could have the same name as the enclosing Storyboard struct,
            // so we must qualify controllerClass with the module name.
            if let customClassName = vc.customClassWithModule {
                return customClassName
            }

            return vc.elementClass
        }
        return nil
    }
}

extension StoryboardFile {
    var storyboardName: String {
        let baseName = URL(fileURLWithPath: fileName).deletingPathExtension().lastPathComponent
        return baseName.replacingOccurrences(of: " ", with: "")
    }
}

extension Scene {
    var segues: [Segue]? {
        return self.children(of: Segue.self, recursive: true)
    }
    var customModule: String? {
        return self.viewController?.viewController.customModule
    }
    var customModuleProvider: String? {
        return self.viewController?.viewController.customModuleProvider
    }
}
typealias Reusable = IBReusable & IBCustomClassable

extension AnyViewController {
    var reusables: [Reusable]? {
        return viewController.reusables
    }
}

extension ViewControllerProtocol {
    var reusables: [Reusable]? {
        var reusables: [Reusable] = []
        reusables.append(contentsOf: self.children(of: CollectionViewCell.self, recursive: true))
        reusables.append(contentsOf: self.children(of: TableViewCell.self, recursive: true))
        return reusables
    }

    var customClassWithModule: String? {
        if let className = self.customClass {
            if let moduleName = self.customModule, customModuleProvider != "target" {
                return "\(moduleName).\(className)"
            } else {
                return className
            }
        }
        return nil
    }
}

extension TargetRuntime {
    var os: OS {
        return OS(targetRuntime: self)
    }
}

extension IBReusable {
    var kind: String {
        if self is CollectionViewCell {
            return "collectionViewCell"
        } else if self is TableViewCell {
            return "tableViewCell"
        } else {
            return ""
        } // XXX maybe lowercase the class (or keep in IBDecodable the xml element name
    }
}

extension Color {

    var assetName: String? {
        switch self {
        case .name(let name):
            return name.name
        default:
            return nil
        }
    }
}
