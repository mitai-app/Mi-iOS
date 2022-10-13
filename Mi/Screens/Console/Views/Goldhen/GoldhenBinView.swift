//
//  GoldhenBinView.swift
//  Mi
//
//  Created by Vonley on 9/28/22.
//

import SwiftUI
import UniformTypeIdentifiers
import UIKit

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
    
    @StateObject private var document: InputDoument = InputDoument()
    @State private var isImporting: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            if(document.files.count > 0) {
                ForEach(document.files.sorted(by: { one, two in
                one.key.lastPathComponent.count > two.key.lastPathComponent.count
                }), id: \.key) { key, value in
                    Row(key: key, value: value)
                        .onTapGesture {
                            document.send()
                        }
                }
                
            }
            VStack (alignment: .center) {
                Button(action: { isImporting = true}, label: {
                    Text("Add Payload")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding()
                }).frame(height: 100)
                .frame(maxWidth: .infinity, alignment: .center).overlay(
                    RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(style: SwiftUI.StrokeStyle.init(lineWidth: 4, dash: [16], dashPhase: 0.0))
                ).padding()
                .foregroundColor(Color("grayDark"))
            }.frame(maxWidth: .infinity)
        }.frame(maxWidth: .infinity)
            .padding(.horizontal)
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: InputDoument.readableContentTypes,
            allowsMultipleSelection: true,
            onCompletion: { result in
                document.handleResult(result: result)
            }
        )
    }
}

struct GoldhenBinView_Previews: PreviewProvider {
    static var previews: some View {
        GoldhenBinView(vm: GoldhenBinViewModel(console: fakeConsoles[0]))
        Row(key: URL(string:"https://google.com/google.bin")!, value: false)
        Row(key: URL(string:"https://google.com/google.bin")!, value: false).preferredColorScheme(.dark)
    }
}

struct Row: View {
    var key: URL
    var value: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "shippingbox.circle")
                .resizable()
                .frame(width: 36, height: 36)
                .foregroundColor(Color("navcolor"))
            VStack(alignment: .leading, spacing: 8) {
                Text("\(key.lastPathComponent)")
                    .foregroundColor(Color("navcolor"))
                    .font(.headline)
                    .fontWeight(.bold)
                Text("type: \(key.pathExtension)")
                    .foregroundColor(.gray)
                    .font(.body)
            }.frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal)
            Image(systemName: "info.circle")
                .resizable()
                .frame(width: 32, height: 32)
                .foregroundColor(.gray)
        }.frame(maxWidth: .infinity, alignment: .leading).padding().background(.white).cornerRadius(20)
    }
}
