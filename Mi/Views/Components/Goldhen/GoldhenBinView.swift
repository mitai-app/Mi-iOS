//
//  GoldhenBinView.swift
//  Mi
//
//  Created by Vonley on 9/28/22.
//

import SwiftUI
import UniformTypeIdentifiers
import UIKit

class InputDoument: FileDocument {

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
extension Dictionary.Keys: Identifiable {
    public var id: UUID {
        return UUID()
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
    
    @State private var document: InputDoument = InputDoument()
    @State private var isImporting: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            VStack (alignment: .center) {
                Button(action: { isImporting = true}, label: {
                    Text("Open File for \(vm.console.name)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding()
                }).background(.white).cornerRadius(10).foregroundColor(Color("quinary"))
            }.frame(maxWidth: .infinity)
            if(document.files.count > 0) {
                VStack {
                Text("Loaded Payloads")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white).padding()
                    ForEach(document.files.sorted(by: { one, two in
                        one.key.lastPathComponent.count > two.key.lastPathComponent.count
                    }), id: \.key) { key, value in
                    VStack(spacing: 8) {
                        HStack {
                            Spacer()
                            Image(systemName: "shippingbox.circle")
                                .resizable()
                                .frame(width: 36, height: 36)
                                .padding(.vertical)
                                .foregroundColor(Color("tertiary"))
                            VStack(alignment: .leading, spacing: 8) {
                                Text("\(key.lastPathComponent)")
                                    .foregroundColor(Color("tertiary"))
                                    .font(.headline)
                                    .fontWeight(.bold)
                                Text("type: \(key.pathExtension)")
                                    .foregroundColor(.gray)
                                    .font(.body)
                            }.padding()
                            Spacer()
                            Image(systemName: "info.circle")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .padding()
                                .foregroundColor(.gray)
                            Spacer()
                        }.background(.white).cornerRadius(10)
                    }.padding(.horizontal).onTapGesture {
                        document.send()
                    }
                }
            }
        
            } else {
                VStack(alignment: .center) {
                    Text("No payloads loaded")
                        .font(.headline)
                        .fontWeight(.bold)
                    .padding().foregroundColor(.white)
                }.frame(maxWidth: .infinity)
            }
        }.frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
        .padding()
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: InputDoument.readableContentTypes,
            allowsMultipleSelection: true,
            onCompletion: { result in
                document.handleResult(result: result)
            }
        ).background(Color("quinary"))
    }
}

struct GoldhenBinView_Previews: PreviewProvider {
    static var previews: some View {
        GoldhenBinView(vm: GoldhenBinViewModel(console: fakeConsoles[0]))
    }
}
