//
//  StoryboardDocument.swift
//  IBGenerateKit
//
//  Created by phimage on 25/08/2019.
//

import Foundation
import IBDecodable

extension StoryboardDocument {

    func processStoryboard(storyboardName: String, os: OS) -> String {
        var output = String()

        output += "\n"
        output += "    struct \(storyboardName): Storyboard {\n"
        output += "\n"
        output += "        static let identifier = \(initIdentifier(for: os.storyboardIdentifierType, value: storyboardName))\n"
        output += "\n"
        output += "        static var storyboard: \(os.storyboardType) {\n"
        output += "            return \(os.storyboardType)(name: self.identifier, bundle: nil)\n"
        output += "        }\n"
        if let initialViewControllerClass = self.initialViewControllerClass {
            let cast = (initialViewControllerClass == os.storyboardControllerReturnType ? (os == OS.iOS ? "!" : "") : " as! \(initialViewControllerClass)")
            output += "\n"
            output += "        static func instantiateInitial\(os.storyboardControllerSignatureType)() -> \(initialViewControllerClass) {\n"
            output += "            return self.storyboard.instantiateInitial\(os.storyboardControllerSignatureType)()\(cast)\n"
            output += "        }\n"
        }
        for (signatureType, returnType) in os.storyboardInstantiationInfo {
            let cast = (returnType == os.storyboardControllerReturnType ? "" : " as! \(returnType)")
            output += "\n"
            output += "        static func instantiate\(signatureType)(withIdentifier identifier: \(os.storyboardSceneIdentifierType)) -> \(returnType) {\n"
            output += "            return self.storyboard.instantiate\(signatureType)(withIdentifier: identifier)\(cast)\n"
            output += "        }\n"

            output += "\n"
            output += "        static func instantiateViewController<T: \(returnType)>(ofType type: T.Type) -> T? where T: IdentifiableProtocol {\n"
            output += "            return self.storyboard.instantiateViewController(ofType: type)\n"
            output += "        }\n"
        }
        for scene in self.scenes ?? [] {
            if let viewController = scene.viewController, let storyboardIdentifier = viewController.viewController.storyboardIdentifier {
                let controllerClass = viewController.viewController.customClass ?? viewController.viewController.elementClass

                let cast = (controllerClass == os.storyboardControllerReturnType ? "" : " as! \(controllerClass)")
                output += "\n"
                output += "        static func instantiate\(swiftRepresentation(for: storyboardIdentifier, firstLetter: .capitalize))() -> \(controllerClass) {\n"
                output += "            return self.storyboard.instantiate\(os.storyboardControllerSignatureType)(withIdentifier: \(initIdentifier(for: os.storyboardSceneIdentifierType, value: storyboardIdentifier)))\(cast)\n"
                output += "        }\n"
            }
        }
        output += "    }\n"

        return output
    }

    func initIdentifier(for identifierString: String, value: String) -> String {
        if identifierString == "String" {
            return "\"\(value)\""
        } else {
            return "\(identifierString)(\"\(value)\")"
        }
    }

    func processViewControllers(storyboardCustomModules: Set<String>) -> String {
        var output = String()

        for scene in self.scenes ?? [] {
            if let viewController = scene.viewController?.viewController {
                if let customClass = viewController.customClass {
                    output += "\n"
                    output += "// MARK: - \(customClass)\n"

                    if let segues = scene.segues?.filter({ return $0.identifier != nil }), !segues.isEmpty {
                        output += "extension \(os.storyboardSegueType) {\n"
                        output += "    func selection() -> \(customClass).Segue? {\n"
                        output += "        if let identifier = self.identifier {\n"
                        output += "            return \(customClass).Segue(rawValue: identifier)\n"
                        output += "        }\n"
                        output += "        return nil\n"
                        output += "    }\n"
                        output += "}\n"
                    }

                    if let storyboardIdentifier = viewController.storyboardIdentifier {
                        output += "protocol \(customClass)IdentifiableProtocol: IdentifiableProtocol { }\n"
                        output += "\n"
                        output += "extension \(customClass): \(customClass)IdentifiableProtocol { }\n"
                        output += "\n"
                        output += "extension IdentifiableProtocol where Self: \(customClass) {\n"

                        let initIdentifierString = initIdentifier(for: os.storyboardSceneIdentifierType, value: storyboardIdentifier)

                        var isCurrentModule = false
                        if let customModule = viewController.customModule {
                            isCurrentModule = !storyboardCustomModules.contains(customModule)
                        }

                        if isCurrentModule {
                            // Accessors for view controllers defined in the current module should be "internal".
                            output += "    var storyboardIdentifier: \(os.storyboardSceneIdentifierType)? { return \(initIdentifierString) }\n"
                        } else {
                            // Accessors for view controllers in external modules (whether system or custom frameworks), should be marked public.
                            output += "    public var storyboardIdentifier: \(os.storyboardSceneIdentifierType)? { return \(initIdentifierString) }\n"
                        }
                        output += "    static var storyboardIdentifier: \(os.storyboardSceneIdentifierType)? { return \(initIdentifierString) }\n"
                        output += "}\n"
                    }

                    if let segues = scene.segues?.filter({ return $0.identifier != nil }), !segues.isEmpty {
                        output += "extension \(customClass) {\n"
                        output += "\n"
                        output += "    enum Segue: \(os.storyboardSegueIdentifierType), CustomStringConvertible, SegueProtocol {\n"
                        for segue in segues {
                            if let identifier = segue.identifier {
                                let swiftIdentifier = swiftRepresentation(for: identifier, firstLetter: .lowercase)
                                if swiftIdentifier == identifier {
                                    output += "        case \(swiftIdentifier)\n"
                                } else {
                                    output += "        case \(swiftIdentifier) = \"\(identifier)\"\n"
                                }
                            }
                        }
                        output += "\n"
                        output += "        var kind: SegueKind? {\n"
                        output += "            switch self {\n"
                        var needDefaultSegue = false
                        for segue in segues {
                            if let identifier = segue.identifier {
                                output += "            case .\(swiftRepresentation(for: identifier, firstLetter: .lowercase)):\n"
                                output += "                return SegueKind(rawValue: \"\(segue.kind)\")\n"
                            } else {
                                needDefaultSegue = true
                            }
                        }
                        if needDefaultSegue {
                            output += "            default:\n"
                            output += "                assertionFailure(\"Invalid value\")\n"
                            output += "                return nil\n"
                        }
                        output += "            }\n"
                        output += "        }\n"
                        output += "\n"
                        output += "        var destination: \(self.os.storyboardControllerReturnType).Type? {\n"
                        output += "            switch self {\n"
                        var needDefaultDestination = false
                        for segue in segues {
                            let destination = segue.destination
                            if let identifier = segue.identifier,
                                let destinationElement = searchById(id: destination) {
                                let destinationClass = destinationElement.customClass ?? destinationElement.elementClass
                                output += "            case .\(swiftRepresentation(for: identifier, firstLetter: .lowercase)):\n"
                                output += "                return \(destinationClass).self\n"
                            } else {
                                needDefaultDestination = true
                            }
                        }
                        if needDefaultDestination {
                            output += "            default:\n"
                            output += "                assertionFailure(\"Unknown destination\")\n"
                            output += "                return nil\n"
                        }
                        output += "            }\n"
                        output += "        }\n"
                        output += "\n"
                        output += "        var identifier: \(os.storyboardSegueIdentifierType)? { return self.rawValue }\n"
                        output += "        var description: String { return \"\\(self.rawValue)\" }\n"
                        output += "    }\n"
                        output += "\n"
                        output += "}\n"
                    }

                    if let reusables = viewController.reusables?.filter({ return $0.reuseIdentifier != nil }), !reusables.isEmpty {

                        output += "extension \(customClass) {\n"
                        output += "\n"
                        output += "    enum Reusable: String, CustomStringConvertible, ReusableViewProtocol {\n"
                        for reusable in reusables {
                            if let identifier = reusable.reuseIdentifier {
                                output += "        case \(swiftRepresentation(for: identifier, doNotShadow: reusable.customClass)) = \"\(identifier)\"\n"
                            }
                        }
                        output += "\n"
                        output += "        var kind: ReusableKind? {\n"
                        output += "            switch self {\n"
                        var needDefault = false
                        for reusable in reusables {
                            if let identifier = reusable.reuseIdentifier {
                                output += "            case .\(swiftRepresentation(for: identifier, doNotShadow: reusable.customClass)):\n"
                                output += "                return ReusableKind(rawValue: \"\(reusable.kind)\")\n"
                            } else {
                                needDefault = true
                            }
                        }
                        if needDefault {
                            output += "            default:\n"
                            output += "                preconditionFailure(\"Invalid value\")\n"
                            output += "                break\n"
                        }
                        output += "            }\n"
                        output += "        }\n"
                        output += "\n"
                        output += "        var viewType: \(self.os.viewType).Type? {\n"
                        output += "            switch self {\n"
                        needDefault = false
                        for reusable in reusables {
                            if let identifier = reusable.reuseIdentifier, let customClass = reusable.customClass {
                                output += "            case .\(swiftRepresentation(for: identifier, doNotShadow: reusable.customClass)):\n"
                                output += "                return \(customClass).self\n"
                            } else {
                                needDefault = true
                            }
                        }
                        if needDefault {
                            output += "            default:\n"
                            output += "                return nil\n"
                        }
                        output += "            }\n"
                        output += "        }\n"
                        output += "\n"
                        output += "        var storyboardIdentifier: String? { return self.description }\n"
                        output += "        var description: String { return self.rawValue }\n"
                        output += "    }\n"
                        output += "\n"
                        output += "}\n"
                    }
                }
            }
        }
        return output
    }
}

extension IBElement {

    func searchById(id: String) -> ViewController? {
        if let element: ViewController = with(id: id) {
            return element
        }
        for child in self.children {
            if let element = child.searchById(id: id) {
                return element
            }
        }
        return nil
    }
}
