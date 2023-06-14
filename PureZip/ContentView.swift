//
//  ContentView.swift
//  PureZip
//
//  Created by lChen on 2023/6/6.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ViewModel()
    @State private var inputPath = "Click or drag the file here."
    @State private var outputPath = ""
    @State private var exclude__MACOSX = false
    @State private var ignoreDS_Store = false
    @State private var ignoreGit = false
    @State private var ignoreSvn = false
    @State private var previewImage = "folder.fill"
    @State private var imageStatus = "plus.circle.fill"
    @State private var imageStatusColor: Color = .gray
    


    var body: some View {
        VStack() {
            Spacer().frame(height: 5)
            Group {
//                HStack {
//                    Text("Target").bold()
//                        .fixedSize()
//
//                    VStack{ Divider() }
//                }.frame(height: 24)
                
//                HStack {
//                    Spacer().frame(width: 10)
//                    Text("Input Path")
//                        .fixedSize()
//                    Spacer().frame(width: 36)
//                    TextField("", text: $inputPath)
//                        .cornerRadius(5)
//                        .frame(minWidth: 350)
//                        .disabled(viewModel.isUIDisable)
//                    Button(action: {
//                        self.browseButtonAction("$inputPath")
//                    }) {
//                        Text("Browse")
//                    }
//                    .frame(minWidth: 120)
//                    .disabled(viewModel.isUIDisable)
//                    .buttonStyle(.borderedProminent)
//                }.frame(height: 24)
                
                Group {
                    AsyncImage(url: URL(string: previewImage)) { image in
                        ZStack(alignment: .bottomTrailing) {
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 75, height: 75)
                                .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                            Image(systemName: imageStatus)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                                .foregroundColor(imageStatusColor)
                        }
                    } placeholder: {
                        ZStack(alignment: .bottomTrailing) {
                            Image(systemName: previewImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 75, height: 75)
                                .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                            Image(systemName: imageStatus)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                                .foregroundColor(imageStatusColor)
                        }
                    }
                    .frame(width: 75, height: 75)
                    .padding()
                    .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                        if let provider = providers.first(where: { $0.canLoadObject(ofClass: URL.self) } ) {
                            let _ = provider.loadObject(ofClass: URL.self) { object, error in
                                if let url = object {
                                    self.viewModel.searchProgress = ""
                                    updatePerviewIcon(url)
                                    
                                    inputPath = self.pathChecker("\(url)")
                                    imageStatus = "checkmark.circle.fill"
                                    imageStatusColor = .green
                                    
                                    let opath = url.deletingLastPathComponent().path
                                    
                                    if outputPath == "" {
                                        outputPath = opath
                                    }
                                }
                            }
                            return true
                        }
                        return false
                    }
                    .onTapGesture {
                        self.browseButtonAction("$inputPath")
                    }
                    .disabled(viewModel.isUIDisable)
                    Text(inputPath)
                }
                
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
                    Spacer()
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
                    Spacer().frame(width: 35)
                    if viewModel.isUIDisable {
                        ProgressView().controlSize(.small)
                        Spacer().frame(width: 10)
                    }
                    Text(viewModel.searchProgress)
                    Spacer()
                }.frame(height: 24)
                Spacer().frame(height: 15)
            }
        }
        .padding()
    }
    
    func browseButtonAction(_ sender: String) {
        let openPanel = NSOpenPanel()
        if sender == "$inputPath" {
            openPanel.canChooseDirectories = true
            openPanel.canChooseFiles = true
        } else if sender == "$outputPath" {
            openPanel.canChooseDirectories = true
            openPanel.canChooseFiles = false
        }
        
        let okButtonPressed = openPanel.runModal() == .OK
        if okButtonPressed {
            // Update the path text field
            let path = openPanel.url?.path
            let opath = openPanel.url?.deletingLastPathComponent().path
            if sender == "$inputPath" {
                self.viewModel.searchProgress = ""
                if let url = openPanel.url {
                    updatePerviewIcon(url)
                }
                
                imageStatus = "checkmark.circle.fill"
                imageStatusColor = .green
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
        if imageStatusColor != .green || outputPath == "" {
            errorMessage = "Path cannot be empty."
        } else if !FileManager.default.fileExists(atPath: inputPath) ||  !FileManager.default.fileExists(atPath: outputPath) {
            errorMessage = "Please check the path."
        }
        guard errorMessage == "" else {
            showAlert(with: .warning, title: "Error", subtitle: errorMessage)
            return
        }
        
        let checkedOutputPath = pathChecker(outputPath)
        let checkedInputPath = pathChecker(inputPath)
        let checkedTargetFile = "file://" + checkedInputPath
        var pureFileName = URL(fileURLWithPath: checkedTargetFile, isDirectory: false).deletingPathExtension().lastPathComponent ?? "zipFile"

        var filePath = checkedOutputPath + "/" + pureFileName
        var count = 0
        while FileManager.default.fileExists(atPath: filePath + ".zip") {
            count += 1
            filePath = checkedOutputPath + "/" + pureFileName + "_\(count)"
        }
        if count != 0 {
            pureFileName = pureFileName + "_\(count)"
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
        viewModel.zipFiles(checkedInputPath, checkedOutputPath, filename: pureFileName, setting: arguSetting)
    }
    
    func pathChecker(_ path: String) -> String {
        var checkedPath = path.replacingOccurrences(of: " ", with: "\\ ")
        checkedPath = checkedPath.replacingOccurrences(of: "file://", with: "")
        checkedPath = checkedPath.removingPercentEncoding ?? checkedPath
        return checkedPath
    }
    
    func updatePerviewIcon(_ url: URL) {
        let imageExtensions = ["png", "jpg", "gif"]
        let docExtensions = ["doc", "docx", "dot", "dotx", "txt", "rtf", "pdf", "odt"]
        let xlsExtensions = ["xls", "xlsx", "csv", "ods"]
        let pptExtensions = ["ppt", "pptx", "odp"]
        let dmgExtensions = ["dmg"]

        let pathExtention = url.pathExtension
        if imageExtensions.contains(pathExtention) {
            previewImage = "\(url)"
        } else if docExtensions.contains(pathExtention) {
            previewImage = "doc.text.fill"
        } else if xlsExtensions.contains(pathExtention) {
            previewImage = "tablecells.fill"
        } else if pptExtensions.contains(pathExtention) {
            previewImage = "note.text"
        } else if dmgExtensions.contains(pathExtention) {
            previewImage = "opticaldiscdrive.fill"
        } else {
            previewImage = "folder.fill"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
