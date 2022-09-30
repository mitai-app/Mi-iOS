//
//  GoldhenBinView.swift
//  Mi
//
//  Created by Vonley on 9/28/22.
//

import SwiftUI
import UniformTypeIdentifiers
import UIKit

struct InputDoument: FileDocument {

    static var bookDocument: UTType {
        UTType(importedAs: "com.mrsmithyx.mi", conformingTo: UTType.data)
        
        }
    static var readableContentTypes: [UTType] { return [bookDocument, UTType.archive, UTType.data]
        
    }

    var input: String

    init(input: String) {
        self.input = input
    }

    init(configuration: FileDocumentReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        input = string
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: input.data(using: .utf8)!)
    }

}

class GoldhenBinViewModel: ObservableObject {
    
    @Published
    var console: Console
    
    init(console: Console) {
        self.console = console
    }
    
    
}

struct GoldhenBinView: View {

    @StateObject var vm: GoldhenBinViewModel
    
    @State private var document: InputDoument = InputDoument(input: "")
    @State private var isImporting: Bool = false

    var body: some View {
        VStack {
            Button(action: { isImporting = true}, label: {
                Text("Open File for \(vm.console.name)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding()
            }).background(grads[1]).cornerRadius(10).foregroundColor(.white)
            Text(document.input)
        }
        .padding()
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.plainText],
            allowsMultipleSelection: false
        ) { result in
            do {
                guard let selectedFile: URL = try result.get().first else { return }
                    if selectedFile.startAccessingSecurityScopedResource() {
                    let data = try Data(contentsOf: selectedFile)
                    guard let input = String(data: data, encoding: .utf8) else {
                            return
                        }
                        defer {
                            selectedFile.stopAccessingSecurityScopedResource()
                        }
                        document.input = input
                        DispatchQueue.global().async {
                            
                            Goldhen.uploadData(data: data)
                        }
                        
                } else {
                    // Handle denied access
                }
            } catch {
                // Handle failure.
                print("Unable to read file contents")
                print(error.localizedDescription)
            }
        }
    }
}

struct GoldhenBinView_Previews: PreviewProvider {
    static var previews: some View {
        GoldhenBinView(vm: GoldhenBinViewModel(console: fakeConsoles[0]))
    }
}
