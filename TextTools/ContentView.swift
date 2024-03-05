//
//  ContentView.swift
//  TextTools
//
//  Created by Nathanael Jenkins on 04/03/2024.
//

import SwiftUI
import AppKit

struct ContentView: View {
    @State private var filesText = ""
    @State private var findText = ""
    @State private var replaceText = ""
    @State private var outputText = ""
    @State private var selectedFilePath: String?

    var body: some View {
        VStack {
            HStack {
                Button("Open File", action: openFile)
                    .padding()
                
                TextField("File(s)", text: $filesText)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            HStack {
                VStack {
                    Text("Find")
                    TextEditor(text: $findText)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                
                VStack {
                    Text("Replace")
                    TextEditor(text: $replaceText)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            }
            .frame(minHeight: 200)
            .padding()
            
            Button("Run") {
                let fileHandler = FileHandler()
                let results = fileHandler.replaceTextInFiles(files: filesText, findText: findText, replaceText: replaceText)
                
                var outputResult = ""
                for (filePath, result) in results {
                    outputResult += "\(filePath): \(result)\n"
                }
                outputText = outputResult
                
                // Clear find and replace text boxes
                findText = ""
                replaceText = ""
            }
            .padding()
            
            // Display the result of print commands in a ScrollView
            VStack {
                Text("Output")
                    .font(.headline)
                ScrollView(.vertical) {
                    Text(outputText)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(nil) // No limit on lines
                        .multilineTextAlignment(.leading)
                }
                .border(Color.gray, width: 1)
                .frame(height: 100)
            }
        }
        .padding()
    }

    private func openFile() {
        let dialog = NSOpenPanel()
        dialog.title = "Choose a file"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.allowsMultipleSelection = true
        dialog.canChooseDirectories = true
        dialog.canCreateDirectories = false
        
        if dialog.runModal() == NSApplication.ModalResponse.OK {
            let result = dialog.url
            if let path = result?.path {
                DispatchQueue.main.async {
                    self.filesText = path
                }
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
