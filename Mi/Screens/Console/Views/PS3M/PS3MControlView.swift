//
//  PS3MControlView.swift
//  Mi
//
//  Created by Vonley on 9/28/22.
//


import SwiftUI

class PS3MControlViewModel: ObservableObject {

    private var console: Console
    private var api = PS3MAPIImpl.init()
    
    @Published var controls: [PS3MapiCommands] = [ ]
    
    init(console: Console) {
        self.console = console
    }
    
    func getPSID() async -> String? {
        return api.getPSID()
    }
    
    
    func getIDPS() async -> String? {
        return api.getIDPS()
    }
    
    func notify(msg: String) async -> String? {
        return api.notify(msg: msg)
    }
    
    
    func getTemperature() async -> Temperature? {
        return api.getTemperature()
    }
    
    
    func getConsoleInfo() async -> ConsoleInfo? {
        return api.getConsoleInfo()
    }
    
    
    func getProcesses() async -> [String] {
        return []
    }
    
    func populate() {
        let enums: [PS3MapiCommands] = [
            .idps, .psid, .notify, .processes, .temperature
        ]
        self.controls = enums
    }
    
}


struct PS3MControlView: View {
    var console: Console
    
    @StateObject var vm: PS3MControlViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("PS3 Manager API")
                .font(.title2)
                .fontWeight(.bold)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60), spacing: 16)], spacing: 16) {
                ForEach(vm.controls) { control in
                    VStack {
                        Image(systemName: control.icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60)
                        Text(control.getTitle()).lineLimit(1)
                    }
                    .onTapGesture {
                        print("tapped \(console)")
                        Task {
                            switch(control) {
                                
                                case .notify:
                                    let notify = await vm.notify(msg: "Welcome")
                                    debugPrint("Notify: \(String(describing: notify))")
                                break;
                                case .idps:
                                    let idps = await vm.getIDPS()
                                    debugPrint("IDPS: \(String(describing: idps))")
                                break
                                case .psid:
                                    let psid = await vm.getPSID()
                                    debugPrint("PSID: \(String(describing: psid))")
                                break
                                
                                case .temperature:
                                    let temp = await vm.getConsoleInfo()
                                    debugPrint("Console Info: \(String(describing: temp))")
                                break
                                
                            default:
                                break
                            }
                        }
                    }
                }
            }
        }
        
        .padding()
        .onAppear {
                vm.populate()
        }
    }
}

struct PS3MControlView_Previews: PreviewProvider {
    static var previews: some View {
        PS3MControlView(console: fakeConsoles[0], vm: PS3MControlViewModel(console: fakeConsoles[0]))
    }
}
