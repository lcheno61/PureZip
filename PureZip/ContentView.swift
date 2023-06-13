//
//  ContentView.swift
//  PureZip
//
//  Created by lChen on 2023/6/6.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ViewModel()
    @State private var inputPath = ""
    @State private var outputPath = ""
    @State private var exclude__MACOSX = false
    @State private var ignoreDS_Store = false
    @State private var ignoreGit = false
    @State private var ignoreSvn = false



    var body: some View {
        VStack(alignment: .leading) {
            Spacer().frame(height: 5)
            Group {
                HStack {
                    Text("Target").bold()
                        .fixedSize()
                    
                    VStack{ Divider() }
                }.frame(height: 24)
                
                HStack {
                    Spacer().frame(width: 10)
                    Text("Input Path")
                        .fixedSize()
                    Spacer().frame(width: 36)
                    TextField("", text: $inputPath)
                        .cornerRadius(5)
                        .frame(minWidth: 350)
                        .disabled(viewModel.isUIDisable)
                    Button(action: {
                        self.browseButtonAction("$inputPath")
                    }) {
                        Text("Browse")
                    }
                    .frame(minWidth: 120)
                    .disabled(viewModel.isUIDisable)
                    .buttonStyle(.borderedProminent)
                }.frame(height: 24)
                
                HStack {
                    Spacer().frame(width: 10)
                    Text("Output Path")
                        .fixedSize()
                    Spacer().frame(width: 25)
                    TextField("", text: $outputPath)
                        .cornerRadius(5)
                        .frame(minWidth: 350)
                        .disabled(viewModel.isUIDisable)
                    Button(action: {
                        self.browseButtonAction("$outputPath")
                    }) {
                        Text("Browse")
                    }
                    .frame(minWidth: 120)
                    .disabled(viewModel.isUIDisable)
                    .buttonStyle(.borderedProminent)
                }.frame(height: 24)
            }
            Group {
                Spacer().frame(height: 15)
                HStack {
                    Text("Setting").bold()
                        .fixedSize()
                    VStack{ Divider() }
                }.frame(height: 24)
                HStack(spacing: 20) {
                    Spacer().frame(width: 1)
                    VStack(alignment: .leading) {
                        Toggle("exclude  __MACOSX", isOn: $exclude__MACOSX).disabled(viewModel.isUIDisable)
                        Toggle("ignore  .DS_store", isOn: $ignoreDS_Store).disabled(viewModel.isUIDisable)
                    }
                    VStack(alignment: .leading) {
                        Toggle("ignore  .git", isOn: $ignoreGit).disabled(viewModel.isUIDisable)
                        Toggle("ignore  .svn", isOn: $ignoreSvn).disabled(viewModel.isUIDisable)
                    }
                }
            }
            Group {
                Spacer().frame(height: 15)
                HStack {
                    Button(action: {
                        self.zipButtonAction()
                    }) {
                        Text("Zip").frame(minWidth: 60)
                    }
                    .disabled(viewModel.isUIDisable)
                    .buttonStyle(.borderedProminent)
                    if viewModel.isUIDisable {
                        Spacer().frame(width: 35)
                        ProgressView().controlSize(.small)
                        Spacer().frame(width: 10)
                    }
                    Text(viewModel.searchProgress)
                    Spacer()
                }.frame(height: 24)
            }
        }
        .padding()
    }
    
    func browseButtonAction(_ sender: String) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        let okButtonPressed = openPanel.runModal() == .OK
        if okButtonPressed {
            // Update the path text field
            let path = openPanel.url?.path
            let opath = openPanel.url?.deletingLastPathComponent().path
            if sender == "$inputPath" {
                inputPath = path!
                if outputPath == "" {
                    outputPath = opath!
                }
            } else if sender == "$outputPath" {
                outputPath = path!
            }
        }
    }

    func showAlert(with style: NSAlert.Style, title: String?, subtitle: String?) {
        let alert = NSAlert()
        alert.alertStyle = style
        alert.messageText = title ?? ""
        alert.informativeText = subtitle ?? ""
        alert.runModal()
    }
    
    func zipButtonAction() {
        
        var errorMessage = ""
        if inputPath == "" || outputPath == "" {
            errorMessage = "Path cannot be empty."
        } else if !FileManager.default.fileExists(atPath: inputPath) ||  !FileManager.default.fileExists(atPath: outputPath) {
            errorMessage = "Please check the path."
        }
        guard errorMessage == "" else {
            showAlert(with: .warning, title: "Error", subtitle: errorMessage)
            return
        }
        var nameOfFile = inputPath.components(separatedBy: "/").last ?? "zipFile"
        var filePath = outputPath + "/" + nameOfFile
        var count = 0
        while FileManager.default.fileExists(atPath: filePath + ".zip") {
            count += 1
            filePath = outputPath + "/" + nameOfFile + "_\(count)"
        }
        if count != 0 {
            nameOfFile = nameOfFile + "_\(count)"
        }
        
        var arguSetting = ""
        if exclude__MACOSX {
            arguSetting = arguSetting.appending(" -x '**/__MACOSX'")
        }
        if ignoreDS_Store {
            arguSetting = arguSetting.appending(" -x \".DS_Store\"")
            arguSetting = arguSetting.appending(" -x \"*.DS_Store\"")
        }
        if ignoreGit {
            arguSetting = arguSetting.appending(" -x \".git\"")
            arguSetting = arguSetting.appending(" -x \"*.git*\"")
        }
        if ignoreSvn {
            arguSetting = arguSetting.appending(" -x \".svn\"")
            arguSetting = arguSetting.appending(" -x \"*.svn*\"")
        }
        
        let checkedOutputPath = outputPath.replacingOccurrences(of: " ", with: "\\ ")
        let checkedInputPath = inputPath.replacingOccurrences(of: " ", with: "\\ ")
//        print("arguSetting: \(arguSetting)")
        viewModel.zipFiles(checkedInputPath, checkedOutputPath, filename: nameOfFile, setting: arguSetting)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
