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
    @State private var findTexts = ["", "", ""]
    @State private var replaceTexts = ["", "", ""]
    @StateObject private var logger = Logger()
    @State private var selectedFilePath: String?
    @State private var showAlert = false
    
    @State private var clearFindBoxes = [false, false, false]
    @State private var clearReplaceBoxes = [false, false, false]
    
    init() {
            // Initialize filesText with the user's home directory
            let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
            _filesText = State(initialValue: homeDirectory.path)
        }
    
    var body: some View {
        VStack {
            HStack {
                Button("Open File", action: openFile)
                    .padding()
                
                TextField("", text: $filesText)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            ForEach(0..<3) { index in
                HStack {
                    VStack {
                        HStack{
                            Text("Find")
                                .font(.headline)
                                .padding([.leading])
                            Spacer()
                            Toggle("Clear on run", isOn: $clearFindBoxes[index])
                                .padding([.trailing])
                        }
                        TextEditor(text: $findTexts[index])
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    
                    VStack {
                        HStack{
                            Text("Replace")
                                .font(.headline)
                                .padding([.leading])
                            Spacer()
                            Toggle("Clear on run", isOn: $clearReplaceBoxes[index])
                                .padding([.trailing])
                        }
                        TextEditor(text: $replaceTexts[index])
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                }
                .frame(minHeight: 100)
                .padding()
            }
            
            HStack{
                Button("Find Files") {
                    logger.clearLog()
                    
                    let fileHandler = FileHandler(logger: logger)
                    fileHandler.findFiles(files: filesText)
                }
                Button("Find Text") {
                    logger.clearLog()
                    
                    let fileHandler = FileHandler(logger: logger)
                    for (index, findText) in findTexts.enumerated() {
                        if !findText.isEmpty {
                            logger.log("====> Searching field \(index+1)")
                            fileHandler.findOccurrencesInFiles(files: filesText, findText: findText)
                        }
                    }
                }
                Button("Find & Replace") {
                    logger.clearLog()
                    
                    let fileHandler = FileHandler(logger: logger)
                    for (index, findText) in findTexts.enumerated() {
                        if !findText.isEmpty {
                            logger.log("====> Searching field \(index+1)")
                            fileHandler.replaceTextInFiles(files: filesText, findText: findText, replaceText: replaceTexts[index])
                            if clearFindBoxes[index] {
                                findTexts[index] = ""
                            }
                            if clearReplaceBoxes[index] {
                                replaceTexts[index] = ""
                            }
                        }
                    }
                }
                Button("Clear Fields") {
                    showAlert = true
                }
                .alert("Warning", isPresented: $showAlert) {
                    Button("Clear") {
                        clearFields()
                    }
                    .keyboardShortcut(.defaultAction)
                    Button("Cancel") {}
                } message: {
                    Text("Are you sure you want to clear all fields?")
                }
            }
            .padding()
            
            // Display the result of print commands in a ScrollView
            ScrollView(.vertical) {
                ScrollViewReader { proxy in
                    Text(logger.outputText)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(nil) // No limit on lines
                        .multilineTextAlignment(.leading)
                        .id("scrollToEnd")
                        .onChange(of: logger.outputText) {
                            // Scroll to the bottom when the content updates
                            withAnimation {
                                proxy.scrollTo("scrollToEnd", anchor: .bottom)
                            }
                        }
                }
            }
            .frame(height: 100)
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
    
    private func clearFields() {
        for (index, _) in findTexts.enumerated() {
            findTexts[index] = ""
            replaceTexts[index] = ""
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
