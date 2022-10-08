//
//  OutputDocument.swift
//  Mi
//
//  Created by Vonley on 10/8/22.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers
import UIKit

class OutputDoument: FileDocument, ObservableObject {

    static var binDocument: UTType { UTType(importedAs: "com.mrsmithyx.mi", conformingTo: UTType.data) }
    static var readableContentTypes: [UTType] { return [.init("public.data")!] }

    @Published var filename: String = ""
    
    @Published var files: [URL: Bool] = [:]
    
    func handleResult(result: Result<[URL], Error>) -> Void {
        do {
            for selectedFile in try result.get() {
                self.filename = selectedFile.lastPathComponent
                self.files[selectedFile] = false
            }
        } catch {
            // Handle failure.
            print("Unable to read file contents")
            print(error.localizedDescription)
        }
    }
    
    func send() {
        DispatchQueue.global().async {
            for (selectedFile, result) in self.files {
                if(!result) {
                    if selectedFile.startAccessingSecurityScopedResource() {
                        do {
                            let data = try Data(contentsOf: selectedFile)
                                let uploaded = Goldhen.uploadData(data: data)
                                debugPrint("\(String(describing: uploaded))")
                                DispatchQueue.main.async { [weak self] in
                                    self?.files[selectedFile] = uploaded
                                    selectedFile.stopAccessingSecurityScopedResource()
                                }
                        } catch {
                            print("Could not send \(error)")
                        }
                    } else {
                        // Handle denied access
                        print("Access denied")
                    }
                } else {
                    print("Already sent, do nothing")
                }
            }
        }
    }
    
    init() {}

    required init(configuration: FileDocumentReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.filename = configuration.file.filename ?? ""
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: filename.data(using: .utf8)!)
    }

}
