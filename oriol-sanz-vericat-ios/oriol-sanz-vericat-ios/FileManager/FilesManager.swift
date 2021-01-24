//
//  FileManager.swift
//  oriol-sanz-vericat-ios
//
//  Created by Oriol Sanz Vericat on 21/01/2021.
//  Copyright © 2021 Oriol Sanz Vericat. All rights reserved.
//

import Foundation

class FilesManager {
    enum Error: Swift.Error {
        case fileAlreadyExists
        case invalidDirectory
        case writtingFailed
        case fileNotExists
        case readingFailed
    }
    let fileManager: FileManager
    let folderName: String
    
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        self.folderName = "AppDataFolder"
        createDirectoryIfNotExists()
    }
    
    func createDirectoryIfNotExists() {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let docURL = URL(string: documentsDirectory)!
        let dataPath = docURL.appendingPathComponent(folderName)
        if !FileManager.default.fileExists(atPath: dataPath.absoluteString) {
            do {
                try FileManager.default.createDirectory(atPath: dataPath.absoluteString, withIntermediateDirectories: false, attributes: nil)
            } catch {
                print(error.localizedDescription);
            }
        }
    }
    
    func save(fileNamed: String, data: Data) throws {
        guard let url = makeURL(forFileNamed: fileNamed) else {
            throw Error.invalidDirectory
        }
        do {
            try data.write(to: url)
        } catch {
            debugPrint(error)
            throw Error.writtingFailed
        }
    }
    
    // The method is responsible for creating the URL of the file with the given name
    private func makeURL(forFileNamed fileName: String) -> URL? {
        guard let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return url.appendingPathComponent(folderName).appendingPathComponent(fileName)
    }
    
    func read(fileNamed: String) throws -> Data {
        guard let url = makeURL(forFileNamed: fileNamed) else {
            throw Error.invalidDirectory
        }
        do {
    
            return try Data(contentsOf: url)
        } catch {
            debugPrint(error)
            throw Error.readingFailed
        }
    }
}
