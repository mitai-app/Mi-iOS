//
//  ConsoleSectionView.swift
//  Mi
//
//  Created by Vonley on 9/25/22.
//

import SwiftUI
import CoreData

class ConsoleViewModel: ObservableObject {

    let container: NSPersistentContainer = PersistenceController.shared.container
    
    init() {
        
    }
    
    
    func addConsole(string: String) {
        SyncServiceImpl.shared.findDevice(ip: string, onSuccess: { console in
            AlertHelper.alert(title: "Success", message: "Console added!") { action in
                
            }
        }, onError: { error in
            AlertHelper.alertDecision(title: "Warning", message: "Unable to verify that this console is on the network. Would you like to still add this console?") { action in
                debugPrint(action.style)
                switch action.style {
                    
                case .default:
                    print("Adding")
                    let console = Console(
                        ip: string,
                        name: string,
                        wifi: "",
                        lastKnownReachable: true, type: PlatformType.unknown,
                        features: [],
                        pinned: false)
                    _ = console.toConsoleEntity(moc: self.container.viewContext)
                    try? self.container.viewContext.save()
                    break;
                case .cancel:
                    print("Canceled")
                    break;
                case .destructive:
                    print("Destroyed")
                    break;
                @unknown default:
                    print("Unknown Default")
                    break;
                }
                
            }
        })
        
    }
 
}

struct ConsoleSectionView: View {
    
    @StateObject var vm = ConsoleViewModel()
    @EnvironmentObject var sync: SyncServiceImpl
    
    @FetchRequest<ConsoleEntity>(
        entity: ConsoleEntity.entity(),
        sortDescriptors: []
    ) var savedEntities: FetchedResults<ConsoleEntity>
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                if sync.active.count > 0 {
                    Text("Found")
                        .font(.title).bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                } else {
                    Text("Searching...")
                        .font(.title).bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
                Menu {
                    Button(action: {
                        alertMessage(
                            title: "Add",
                            message: "Add a new console via ip",
                            placeholder: "console ip",
                            onConfirm: { string in
                                vm.addConsole(string: string)
                            }) {
                                // do nothing
                            }
                    }) {
                        Text("Add Console")
                        Image(systemName: "plus.circle")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                    
                    Button(action: {
                        SyncServiceImpl.shared.findDevices { consoles in
                            print("Consoles found: \(consoles.count)")
                        } onError: { error in
                            print(error)
                        }
                    }) {
                        Text("Scan Network")
                        Image(systemName: "network")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .resizable()
                        .frame(width: 24, height: 24)
                }.padding().foregroundColor(Color("navcolor"))
            }
            ScrollView(.vertical) {
                ForEach(savedEntities) { item in
                    ConsoleListItem(console: item.fromConsoleEntity())
                }
            }
        }.refreshable {
            sync.findDevices { consoles in
                
            }
        }.onAppear {
            
        }
    }
}

struct ConsoleSectionView_Previews: PreviewProvider {
    static var previews: some View {
        ConsoleSectionView()
            .environmentObject(SyncServiceImpl.test())
    }
}
