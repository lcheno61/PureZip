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
        
//        func removeDSStoreFiles(_ path: String){
//
//            let task = Process()
//            task.launchPath = "/usr/bin/find"
//            let para = [path, "-name", ".DS_Store", "-delete"]
//            task.arguments = para
//            task.launch()
//        }
        
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
            
            let cmd = "cd \(inputPath) && zip -r \(filename).zip . \(setting) && mv \(filename).zip \(outputPath)"
            
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

    }
}
