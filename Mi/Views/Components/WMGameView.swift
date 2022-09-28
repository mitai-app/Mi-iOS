//
//  WMGameView.swift
//  Mi
//
//  Created by Vonley on 9/25/22.
//

import SwiftUI
import Kingfisher

class WebmanGameViewModel: ObservableObject {
    
    @Published var games: [Game] = []

    init(games: [Game]) {
        self.games = games
    }
    
    init() {
        
    }
    
    func playGame(console: Console, game: Game) async {
        WebMan.play(ip: console.ip, game: game) { response in
            
        }
    }
    
    func getGames(console: Console) async {
        WebMan.getGames(ip: console.ip, onComplete: { res in
            do {
                if let data = try res.result.get() {
                    let games = Game.parse(ip: console.ip, data: data)
                    DispatchQueue.main.async { [weak self] in
                        
                        self?.games = games
                    }
                }
            }catch {
                
            }
            
        })
    }
    
}

struct WMGameView: View {
    
    @StateObject var vm = WebmanGameViewModel()
    
    var console: Console = fakeConsoles[0]
    
    var body: some View {
        VStack {
            Text("Games")
                .font(.title2)
                .fontWeight(.bold)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 16)], spacing: 16) {
                ForEach(vm.games) { game in
                    VStack {
                        KFImage(URL(string: game.icon))
                            .placeholder {
                                
                                Image(systemName: "gear")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 90)
                            }
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 90)
                        Text(game.title).lineLimit(1)
                    }.onTapGesture {
                        Task {
                            await vm.playGame(console: console, game: game)
                        }
                    }
                }
            }
        }.padding()
            .onAppear {
                Task {
                    await vm.getGames(console: console)
                }
            }
    }
}

struct WMGameView_Previews: PreviewProvider {
    static var previews: some View {
        WMGameView(vm: WebmanGameViewModel(games: fakeGames))
    }
}
