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
        return await api.getPSID()
    }
    
    func beep() async -> String? {
        return await api.buzz(mode: 1)
    }
    
    func getIDPS() async -> String? {
        return await api.getIDPS()
    }
    
    func notify(msg: String) async -> String? {
        return await api.notify(msg: msg)
    }
    
    
    func getTemperature() async -> Temperature? {
        return await api.getTemperature()
    }
    
    
    func getConsoleInfo() async -> ConsoleInfo? {
        return await api.getConsoleInfo()
    }
    
    
    func getProcesses() async -> [String] {
        return []
    }
    
    func populate() {
        let enums: [PS3MapiCommands] = [
            .notify, .buzzer, .idps, .psid, .temperature
        ]
        self.controls = enums
    }
    
}


struct PS3MControlView: View {
    var console: Console
    @Binding var consoleInfo: ConsoleInfo?
    @StateObject var vm: PS3MControlViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("PS3 Manager API")
                .font(.title3)
                .fontWeight(.bold)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40), spacing: 32)], spacing: 32) {
                ForEach(vm.controls) { control in
                    VStack {
                        Image(systemName: control.icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40)
                        if #available(iOS 15.0, *) {
                            Text(control.getTitle())
                                .bold()
                                .dynamicTypeSize(.xSmall)
                                .lineLimit(1)
                        } else {
                            Text(control.getTitle())
                                .bold()
                                .sizeCategory(.extraSmall)
                                .lineLimit(1)
                        }
                    }
                    .onTapGesture {
                        print("tapped \(console)")
                        switch(control) {
                            case .buzzer:
                            Task(priority: .background) {
                                _ = await vm.beep()
                            }
                            break
                            case .notify:
                            alertMessage(title: "Notify", message: "What do you want to say?", placeholder: "Message here...") { string in
                                Task {
                                    let notify = await vm.notify(msg: string)
                                    debugPrint("Notify: \(String(describing: notify))")
                                }
                            } onCancel: {
                            
                            }
                            break;
                            case .idps:
                            Task(priority: .background) {
                                let idps = await vm.getIDPS()
                                debugPrint("IDPS: \(String(describing: idps))")
                                await MainActor.run {
                                    idps?.copyToClipboard()
                                }
                            }
                            break
                            case .psid:
                            Task(priority: .background) {
                                let psid = await vm.getPSID()
                                debugPrint("PSID: \(String(describing: psid))")
                                await MainActor.run {
                                    psid?.copyToClipboard()
                                }
                            }
                            break
                            case .temperature:
                            Task(priority: .background) {
                                let temp = await vm.getConsoleInfo()
                                debugPrint("Console Info: \(String(describing: temp))")
                                await MainActor.run {
                                    consoleInfo = temp
                                }
                            }
                            break
                            
                        default:
                            break
                        }
                    }
                }
            }
        }
        .padding()
        .onAppear {
            vm.populate()
            
            Task(priority: .background) {
                let temp = await vm.getConsoleInfo()
                debugPrint("Console Info: \(String(describing: temp))")
                await MainActor.run {
                    consoleInfo = temp
                }
            }
        }
    }
}

struct PS3MControlView_Previews: PreviewProvider {
    static var previews: some View {
        PS3MControlView(console: fakeConsoles[0], consoleInfo: .constant(nil), vm: PS3MControlViewModel(console: fakeConsoles[0]))
    }
}
