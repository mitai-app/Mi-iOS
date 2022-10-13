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
        Webman.play(ip: console.ip, game: game) { response in
            
        }
    }
    
    func getGames(console: Console) async {
        Webman.getGames(ip: console.ip, onComplete: { res in
            Task(priority: .background) {
                do {
                    if let data = try res.result.get() {
                        let games = Game.parse(ip: console.ip, data: data)
                        await MainActor.run {
                            self.games = games
                        }
                    }
                }catch {
                    
                }
            }
            
        })
    }
    
}

struct WMGameView: View {
    
    @StateObject var vm = WebmanGameViewModel()
    
    var console: Console = fakeConsoles[0]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Games")
                .font(.title2)
                .fontWeight(.bold)
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(vm.games) { game in
                        VStack(spacing: 0) {
                            VStack {
                                KFImage(URL(string: game.icon))
                                    .placeholder {
                                        Image(systemName: "gear")
                                            .resizable()
                                            .padding()
                                            .aspectRatio(contentMode: .fit)
                                    }
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                            VStack {
                                Text(game.title)
                                    .lineLimit(1)
                                    .padding()
                                    .foregroundColor(Color("foreground"))
                            }
                        }
                        .frame(maxWidth: 150)
                        .onTapGesture {
                            Task(priority: .background) {
                                await vm.playGame(console: console, game: game)
                            }
                        }
                    }
                }
            }
        }.padding().frame(maxHeight: 300)
            .onAppear {
                Task(priority: .background) {
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
