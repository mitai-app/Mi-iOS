//
//  WMControlView.swift
//  Mi
//
//  Created by Vonley on 9/25/22.
//

import SwiftUI
class WMControlViewModel: ObservableObject {

    private var console: Console
    
    @Published var controls: [WebmanCommands] = []
    
    init(console: Console) {
        self.console = console
    }
    
    func beep() async {
        Webman.beep(ip: console.ip) { res in
            
        }
    }
    
    func reboot() async  {
        Webman.reboot(ip: console.ip, boot: .reboot ) { res in
            
        }
    }

    func shutdown() async {
        Webman.shutdown(ip: console.ip) { res in
            
        }
    }
    
    func refresh() async {
        Webman.refresh(ip: console.ip) { res in
            
        }
    }
    
    func insert() async {
        Webman.insert(ip: console.ip) { res in
            
        }
    }
    
    func eject() async  {
        Webman.eject(ip: console.ip) { res in
            
        }
    }
    
    func unmount() async {
        Webman.unmount(ip: console.ip) { res in
            
        }
    }
    
    
    func populate() {
        let enums = [
            WebmanCommands.beep,
            WebmanCommands.reboot,
            WebmanCommands.shutdown,
            WebmanCommands.refresh,
            WebmanCommands.insert,
            WebmanCommands.eject,
            WebmanCommands.unmount,
        ]
        self.controls = enums
    }
    
}


struct WMControlView: View {
    var console: Console
    
    @StateObject var vm: WMControlViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Controls")
                .font(.title2)
                .fontWeight(.bold)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60), spacing: 16)], spacing: 16) {
                ForEach(vm.controls) { control in
                    VStack {
                        Image(systemName:control.iconName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width:60)
                        Text(control.title).lineLimit(1)
                    }
                    .onTapGesture {
                        Task {
                            switch(control) {
                                case .beep:
                                await vm.beep()
                                    break;
                                case .reboot:
                                await vm.reboot()
                                    break;
                                case .shutdown:
                                await vm.shutdown()
                                    break;
                                case .refresh:
                                await vm.refresh()
                                    break;
                                case .insert:
                                await vm.insert()
                                    break;
                                case .eject:
                                await vm.eject()
                                    break;
                                case .unmount:
                                await vm.unmount()
                                    break;
                                default:
                                    break;
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

struct WMControlView_Previews: PreviewProvider {
    static var previews: some View {
        WMControlView(console: fakeConsoles[0], vm: WMControlViewModel(console: fakeConsoles[0]))
    }
}
