# IBGenerate
[![Build Status](https://travis-ci.org/IBDecodable/IBGenerate.svg?branch=master)](https://travis-ci.org/IBDecodable/IBGenerate)
[![Swift 5.0](https://img.shields.io/badge/Swift-5.0-orange.svg?style=flat)](https://developer.apple.com/swift/)

A tool to generate a code from your  `.storyboard` files to reduce the usage of `String` as identifiers for Segues or Storyboards.

:warning: `ibgenerate` work only for `iOS` for the moment.

## What the command generate exactly?

### Storyboards list

 A `Storyboards` struct with convenient functions to instanciate your view controllers.
 
```swift
struct Storyboards {
  struct Main {...}
  struct Second {...}
```

Instantiate initial view controller for storyboard

```swift
let vc = Storyboards.Main.instantiateInitialViewController()
```

### Enumeration for segues

```swift
extension MyViewController {

  enum Segue: String, CustomStringConvertible, SegueProtocol {
    case segueToFirst
    case segueToSecond

```

Enum that you can use with `IBStoryboard` function

```swift
self.performSegue(MainViewController.Segue.segueToFirst, sender:nil)
```

### Enumeration for named colors

Storyboard could use named colors, and sometimes you need it also in your code and do not want to use the string.
So an enum is generated.

Could be desactivated in configuration file
```ruby
color: false
```

This also could be generated by reading xcode assets.

## Install ibgenerate

### Using sources

```
git clone https://github.com/IBDecodable/IBGenerate.git
cd IBGenerate
make install
```

### Using Homebrew (swiftbrew)

If not already installed yet, install [Swiftbrew](https://github.com/swiftbrew/Swiftbrew) with [Homebrew](https://brew.sh/index_fr)

```
brew install swiftbrew/tap/swiftbrew
```

then type 
```
swift brew install IBDecodable/IBGenerate
```

## Usage

You can see all description by `ibgenerate help`

```
$ ibgenerate help
Available commands:

   help      Display general or command-specific help
   generate  Generate code (default command)
   version   Display the current version of ibgenerate
```

### Generate command

In your working directory, or by passing the `path` option, launch the command to see the generated code.

```
$ ibgenerate
//
// Autogenerated by ibgenerate - Storyboard Generator
//
import UIKit
import IBStoryboard

// MARK: - Storyboards
struct Storyboards {
```

You can redirect the ouput to a `Storyboards.swift` file, like done in next step.

### Xcode integration

Add a `Run Script Phase` to integrate IBGenerate with Xcode to generate the `Storyboards.swift`

```sh
if which ibgenerate >/dev/null; then
  echo "ibgenerate: Determining if generated Swift file is up-to-date."

  BASE_PATH="$PROJECT_DIR/$PROJECT_NAME"
  OUTPUT_PATH="$BASE_PATH/Storyboards.swift"

  if [ ! -e "$OUTPUT_PATH" ] || [ -n "$(find "$BASE_PATH" -type f -name "*.storyboard" -newer "$OUTPUT_PATH" -print -quit)" ]; then
    echo "ibgenerate: Generated Swift is out-of-date; re-generating..."

  /usr/bin/chflags nouchg "$OUTPUT_PATH"
  ibgenerate > "$OUTPUT_PATH"
  /usr/bin/chflags uchg "$OUTPUT_PATH"

  echo "ibgenerate: Done."
  else
    echo "ibgenerate: Generated Swift is up-to-date; skipping re-generation."
  fi
else
  echo "warning: IBGenerate not installed, download from https://github.com/IBDecodable/IBGenerate"
fi
```

You can configure to generate a swift file by target using the storyboard referenced in build phases targets.
```ruby
xcodeTarget: true
```

## Requirements

IBGenerate requires Swift5.0 runtime. Please satisfy at least one of following requirements.

 - macOS 10.14.4 or later
 - Install `Swift 5 Runtime Support for Command Line Tools` from [More Downloads for Apple Developers](https://developer.apple.com/download/more/)
 
## Configuration

You can configure IBGenerate by adding a `.ibgenerate.yml` file from project root directory.


| key                  | description                 |
|:---------------------|:--------------------------- |
| `excluded`           | Path to ignore.    |
| `included`           | Path to include.   |
| `color`                 | Generate or not enum for color (default true).   |
| `imports`             | Add in generated code some additionnals imports. Could be useful if failed to detect it or objc.   |
| `xcodeTarget`     | In Xcode environment and target get storyboards from target build phase.   |

```yaml
included:
  - ImportantViews
```

## Acknowledgement

This projects is heavily inspired by [natalie](https://github.com/krzyzanowskim/Natalie) @Marcin Krzyżanowski

*I ,phimage, do some work on it, `macOS` compatibility, and decode storyboard into objects, etc...*

The main difference is that this project only generate the dynamic part of the code, the code generated from your storyboards.

The common code is in [IBStoryboard](https://github.com/IBDecodable/IBStoryboard) package and could be imported using SwiftPM.

```swift
import PackageDescription

let package = Package(
...
dependencies: [
.package(url: "https://github.com/IBDecodable/IBStoryboard.git", .revision("HEAD"))
...

```

Then `ibgenerate` is more configurable to add new features.
