//
//  FileHandler.swift
//  TextTools
//
//  Created by Nathanael Jenkins on 04/03/2024.
//

import Foundation

class Logger: ObservableObject {
    @Published var outputText = ""

    // Function to log messages
    func log(_ message: String) {
        outputText += "\(message)\n"
    }

    // Clear the log
    func clearLog() {
        outputText = ""
    }
}

class FileHandler: ObservableObject {
    // Use logger
    let logger: Logger

    init(logger: Logger) {
        self.logger = logger
    }
    
    
    func replaceTextInFiles(files: String, findText: String, replaceText: String) {
        let filesArray = expandWildcards(pattern: files)

        for filePath in filesArray {
            // Perform the text replacement in each file
            if let content = readFileContent(filePath: filePath) {
                let updatedContent = content.replacingOccurrences(of: findText, with: replaceText)
                writeToFile(filePath: filePath, content: updatedContent)
                logger.log("\(filePath): Success")
            } else {
                logger.log("\(filePath): Error reading file.")
            }
        }

        return
    }
    
    func findOccurrencesInFiles(files: String, findText: String) {
        let filesArray = expandWildcards(pattern: files)

        for filePath in filesArray {
            // Perform the text search in each file
            if let content = readFileContent(filePath: filePath) {
                let occurrences = content.components(separatedBy: findText).count - 1
                logger.log("\(filePath): \(occurrences)")
            } else {
                logger.log("\(filePath): Error reading file.")
            }
        }
    }
    
    func findFiles(files: String) {
        let filesArray = expandWildcards(pattern: files)

        for filePath in filesArray {
            logger.log(filePath)
        }
    }

    func expandWildcards(pattern: String) -> [String] {
        var gt = glob_t()
        defer { globfree(&gt) }

        guard glob(pattern, 0, nil, &gt) == 0 else {
            return []
        }

        let files = (0..<Int(gt.gl_pathc)).compactMap {
            String(cString: gt.gl_pathv[$0]!)
        }

        return files
    }

    func readFileContent(filePath: String) -> String? {
        do {
            let content = try String(contentsOfFile: filePath, encoding: .utf8)
            return content
        } catch {
            logger.log("Error reading file: \(error.localizedDescription)")
            return nil
        }
    }

    func writeToFile(filePath: String, content: String) {
        do {
            try content.write(toFile: filePath, atomically: true, encoding: .utf8)
        } catch {
            logger.log("Error writing to file: \(error.localizedDescription)")
        }
    }
}


extension String {
    // Helper method to check if a string matches a given pattern
    func matches(pattern: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let range = NSRange(location: 0, length: self.utf16.count)
            return regex.firstMatch(in: self, options: [], range: range) != nil
        } catch {
            return false
        }
    }
}
