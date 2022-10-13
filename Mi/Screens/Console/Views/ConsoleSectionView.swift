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
        let request = ConsoleEntity.fetchRequest()
        do {
            let ok = FetchRequest(fetchRequest: request)
        } catch let error {
            print("Error fetching. \(error)")
        }
    }
    
    
    func addConsole(string: String) {
        let console = Console(
            ip: string,
            name: string,
            wifi: "",
            lastKnownReachable: true, type: PlatformType.unknown,
            features: [],
            pinned: false)
        console.toConsoleEntity(moc: container.viewContext)
        try? container.viewContext.save()
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
                }, label: {
                    Image(systemName: "plus.circle")
                        .resizable()
                        .frame(width: 24, height: 24)
                }).padding().foregroundColor(Color("navcolor"))
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
