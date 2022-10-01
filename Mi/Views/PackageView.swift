//
//  PackageView.swift
//  Mi
//
//  Created by Vonley on 9/30/22.
//

import SwiftUI
import FilesProvider

class PackageViewModel: ObservableObject {
    
    private var target: Console? {
        return SyncService.shared.target
    }
    
    @Published var response: PackageResponse!
    
    init() {}
    
    func searchPackages(search: String) {
        Package.searchBin(search: search) { [weak self] response in
            self?.response = response
        }
    }
    
}

struct PackageView: View {
    
    @State var show = false
    @State var search = ""
    
    @StateObject var sync: SyncService
    @State var background: Color
    
    @StateObject var vm: PackageViewModel = PackageViewModel()
    
    
    
    var body: some View {
        CustomNavView {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    VStack {
                        TextField("", text: $search)
                            .placeholder(when: search.isEmpty) {
                                Text("Enter url...").foregroundColor(Color.gray)
                            }
                            .padding()
                            .background(Color("grayDark"))
                            .cornerRadius(10)
                        
                            .onChange(of: search) { newValue in
                                    vm.searchPackages(search: newValue)
                            }.foregroundColor(.white)
                            .accentColor(.red)
                            .shadow(color: Color.black.opacity(1), radius: 5, x:0, y:4)
                    }
                        .padding()
                    
                    ForEach(0..<5) { item in
                        VStack(alignment: .leading, spacing: 8) {
                            Text("\(item)")
                        }.background(.white)
                            .cornerRadius(20).padding()
                    }
                }
            }
            .background(background)
            .foregroundColor(.white)
            .refreshable {
                    
            }.customNavigationTitle("Packages")
            .customNavigationBarBackButtonHidden(true)
            .onAppear {
                vm.searchPackages(search: search)
            }
        }
    }
}


struct PackageView_Previews: PreviewProvider {
    static var previews: some View {
        PackageView(sync: SyncService.test(), background: Color("quinary"))
    }
}


extension View {
    func placeholder<Content: View>(
            when shouldShow: Bool,
            alignment: Alignment = .leading,
            @ViewBuilder placeholder: () -> Content) -> some View {

            ZStack(alignment: alignment) {
                placeholder().opacity(shouldShow ? 1 : 0)
                self
            }
        }
}
