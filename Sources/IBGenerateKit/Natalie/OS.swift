import IBDecodable

extension OS {

    static let allValues = [iOS]
    
    enum Runtime: String {
        case iOSCocoaTouch = "iOS.CocoaTouch"
        case MacmacOSCocoa = "MacmacOS.Cocoa"
        case AppleTV = "AppleTV"
        
        init(os: OS) {
            switch os {
            case iOS:
                self = .iOSCocoaTouch
            case macOS:
                self = .MacmacOSCocoa
            case tvOS:
                self = .AppleTV
            }
        }
    }
    
    enum Framework: String {
        case UIKit = "UIKit"
        case Cocoa = "Cocoa"
        
        init(os: OS) {
            switch os {
            case iOS, .tvOS:
                self = .UIKit
            case macOS:
                self = .Cocoa
            }
        }
    }

    var description: String {
        return self.rawValue
    }
    
    var framework: String {
        return Framework(os: self).rawValue
    }
    
    var targetRuntime: String {
        return Runtime(os: self).rawValue
    }
    
    var storyboardType: String {
        switch self {
        case .iOS, .tvOS:
            return "UIStoryboard"
        case .macOS:
            return "NSStoryboard"
        }
    }
    
    var storyboardIdentifierType: String {
        switch self {
        case .iOS, .tvOS:
            return "String"
        case .macOS:
            return "NSStoryboard.Name"
        }
    }

    var storyboardSceneIdentifierType: String {
        switch self {
        case .iOS, .tvOS:
            return "String"
        case .macOS:
            return "NSStoryboard.SceneIdentifier"
        }
    }

    var storyboardSegueType: String {
        switch self {
        case .iOS, .tvOS:
            return "UIStoryboardSegue"
        case .macOS:
            return "NSStoryboardSegue"
        }
    }

    var storyboardSegueIdentifierType: String {
        switch self {
        case .iOS, .tvOS:
            return "String"
        case .macOS:
            return "NSStoryboardSegue.Identifier"
        }
    }

    var storyboardControllerTypes: [String] {
        switch self {
        case .iOS, .tvOS:
            return ["UIViewController"]
        case .macOS:
            return ["NSViewController", "NSWindowController"]
        }
    }
    
    var storyboardControllerReturnType: String {
        switch self {
        case .iOS, .tvOS:
            return "UIViewController"
        case .macOS:
            return "AnyObject" // NSViewController or NSWindowController
        }
    }
    
    var storyboardControllerSignatureType: String {
        switch self {
        case .iOS, .tvOS:
            return "ViewController"
        case .macOS:
            return "Controller" // NSViewController or NSWindowController
        }
    }
    
    var storyboardInstantiationInfo: [(String /* Signature type */, String /* Return type */)] {
        switch self {
        case .iOS, .tvOS:
            return [("ViewController", "UIViewController")]
        case .macOS:
            return [("Controller", "NSWindowController"), ("Controller", "NSViewController")]
        }
    }
    
    var viewType: String {
        switch self {
        case .iOS, .tvOS:
            return "UIView"
        case .macOS:
            return "NSView"
        }
    }
    
    var colorType: String {
        switch self {
        case .iOS, .tvOS:
            return "UIColor"
        case .macOS:
            return "NSColor"
        }
    }
    
    var colorNameType: String {
        switch self {
        case .iOS, .tvOS:
            return "String"
        case .macOS:
            return "NSColor.Name"
        }
    }
    
    var colorOS: String {
        switch self {
        case .iOS:
            return "iOS 11.0"
        case .tvOS:
            return "tvOS 11.0"
        case .macOS:
            return "macOS 10.13"
        }
    }
    
    var resuableViews: [String]? {
        switch self {
        case .iOS, .tvOS:
            return ["UICollectionReusableView", "UITableViewCell"]
        case .macOS:
            return nil
        }
    }
    
    func controllerType(for name: String) -> String? {
        switch self {
        case .iOS, .tvOS:
            switch name {
            case "viewController":
                return "UIViewController"
            case "navigationController":
                return "UINavigationController"
            case "tableViewController":
                return "UITableViewController"
            case "tabBarController":
                return "UITabBarController"
            case "splitViewController":
                return "UISplitViewController"
            case "pageViewController":
                return "UIPageViewController"
            case "collectionViewController":
                return "UICollectionViewController"
            case "exit", "viewControllerPlaceholder":
                return nil
            default:
                assertionFailure("Unknown controller element: \(name)")
                return nil
            }
        case .macOS:
            switch name {
            case "viewController":
                return "NSViewController"
            case "windowController":
                return "NSWindowController"
            case "pagecontroller":
                return "NSPageController"
            case "tabViewController":
                return "NSTabViewController"
            case "splitViewController":
                return "NSSplitViewController"
            case "exit", "viewControllerPlaceholder":
                return nil
            default:
                assertionFailure("Unknown controller element: \(name)")
                return nil
            }
        }
    }
    
}
