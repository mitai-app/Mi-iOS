//
//  ConsoleListItem.swift
//  Mi
//
//  Created by Vonley on 9/25/22.
//

import SwiftUI

struct ConsoleListItem: View {
    var console: Console
    @State var show: Bool = false
    @EnvironmentObject var sync: SyncServiceImpl
    
    var body: some View {
        VStack {
            HStack {
                HStack {
                    if console.isPs4 || console.isPs3 {
                        Image(systemName: "antenna.radiowaves.left.and.right.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 36, height: 36, alignment: .center)
                        
                    } else {
                        Image(systemName: "network")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 36, height: 36, alignment: .center)
                    }
                }
                .padding(4)
                VStack(alignment: .leading, spacing: 4) {
                    Text(console.name)
                        .font(.title3).bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(console.ip)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }.padding(.horizontal)
            }.padding(.horizontal)
            if show {
                ConsoleFeatureView(item: console)
            }
        }.foregroundColor(sync.target?.ip == console.ip ? Color("quaternary") : Color.gray)
        .onTapGesture {
            print("Setting Console: \(console.ip)")
            sync.target = console
            withAnimation(Animation.easeInOut(duration: 0.5)) {
                show.toggle()
            }
        }
    }
}

struct ConsoleListItem_Previews: PreviewProvider {
    
    
    static var previews: some View {
        VStack {
            ConsoleListItem(console: fakeConsoles[0])
                .environmentObject(SyncServiceImpl.test())
            ConsoleListItem(console: fakeConsoles[1])
                .environmentObject(SyncServiceImpl.test())
            Spacer()
        }
        VStack {
            ConsoleListItem(console: fakeConsoles[0])
                .environmentObject(SyncServiceImpl.test()).colorScheme(.dark)
            ConsoleListItem(console: fakeConsoles[1])
                .environmentObject(SyncServiceImpl.test()).colorScheme(.dark)
            
        Spacer()
        }.colorScheme(.dark)
    }
}
