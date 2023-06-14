//
//  viewModel.swift
//  PureZip
//
//  Created by lChen on 2023/6/6.
//

import Foundation

extension ContentView {
    class ViewModel: ObservableObject {
        
        @Published var isUIDisable = false
        @Published var searchProgress = ""

        var dataLock: NSLock?
        
        init() {
            dataLock = NSLock()
        }
        
        func doZipFile(_ command: String) -> Bool {
            dataLock = NSLock()
            let task = Process()
            task.launchPath = "/bin/sh"
            let para = ["-c", command]
            task.arguments = para
            let pipe = Pipe()
            task.standardOutput = pipe
            task.launch()
            let file = pipe.fileHandleForReading
            let data = file.readDataToEndOfFile()
            dataLock!.unlock()
            guard let output = String(data: data, encoding: .utf8) else { return false }
            if output.contains("zip error:") {
                return false
            } else {
                return true
            }
        }
        
        func zipFiles(_ inputPath: String,_ outputPath: String, filename: String, setting: String) {
            searchProgress = "Zipping"
            isUIDisable = true
            print("inputPath: " + inputPath)
            print("outputPath: " + outputPath)
            print("filename: " + filename)
            var cmd = ""
            let addPercentInputPath = inputPath.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? inputPath
            let addPercentOutputPath = outputPath.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? outputPath
            let checkedTargetFile = "file://" + addPercentInputPath
            let checkedFileName = filename
            if let targetFileURL = URL(string: checkedTargetFile) {
                let isDirectory = targetFileURL.pathExtension == "" ? true : false//(try? targetFileURL.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory ?? false
                if isDirectory {
                    cmd = "cd \(inputPath) && zip -r \(checkedFileName).zip . \(setting) && mv \(checkedFileName).zip \(outputPath)"
                } else {
                    let pureFileName = URL(fileURLWithPath: checkedTargetFile, isDirectory: false).deletingPathExtension().lastPathComponent
                    let fName = filename.replacingOccurrences(of: "\\ ", with: " ")
                    let folderName = createDirectory(fName).replacingOccurrences(of: " ", with: "\\ ")
                    print("folderName: " + folderName)
                    let cpFileName = folderName + "/" + checkedFileName + "." + targetFileURL.pathExtension
                    cmd = "cd \(folderName) && cp \(inputPath) \(cpFileName) && zip -r \(checkedFileName).zip . \(setting) && mv \(checkedFileName).zip \(outputPath) && rm -r \(folderName)"
                }
            }
            
            DispatchQueue.global(qos: .background).async {
                let zipResult =  self.doZipFile(cmd)
                DispatchGroup().notify(queue: DispatchQueue.main) {
                    DispatchQueue.main.async {
                        self.isUIDisable = false
                        if zipResult {
                            self.searchProgress = "Finish"
                        } else {
                            self.searchProgress = "Zip Error"
                        }
                    }
                }
            }
        }
        
        func createDirectory(_ name: String) -> String {
            let paths = NSSearchPathForDirectoriesInDomains(.downloadsDirectory, .userDomainMask, true)
            let documentsDirectory = paths[0]
            let docURL = URL(string: documentsDirectory)!
            let dataPath = docURL.appendingPathComponent(name).deletingPathExtension()
            do {
                try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
                return dataPath.path
            } catch {
                print(error.localizedDescription)
                return ""
            }
        }

    }
}
