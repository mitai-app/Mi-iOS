//
//  ArticleView.swift
//  Mi
//
//  Created by Vonley on 10/10/22.
//

import SwiftUI
import Kingfisher

struct ArticleView: View {
    
    @Environment(\.openURL) private var openURL
    
    let article: Article
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text(article.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if let desc = article.description {
                    Text(desc)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }.padding(30)
            ZStack(alignment: .bottom) {
                if let img = article.icon {
                    ZStack {
                        if img.verifyUrl() {
                            KFImage(URL(string: img))
                                .placeholder {
                                    Image("money")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                }
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .background(.white)
                        } else {
                            Image(img)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .background(.white)
                        }
                    }.frame(maxHeight: 240)
                }
            }
            .cornerRadius(20)
            .frame(alignment: .leading)
        }
        .background(article.background)
        .foregroundColor(.white)
        .cornerRadius(20)
        .padding()
        .onTapGesture {
            if article is BasicViewType {
                
            } else if article is ProfileViewType {
                
            } else if article is PayloadViewType {
                
            } else if article is ReadableViewType {
                
            }
            
            if let link = article.link {
                if let url = URL(string: link) {
                    openURL(url)
                }
            }
        }
    }
}

struct ArticleView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(0..<Constants.ARTICLES.count) { article in
            ArticleView(article: Constants.ARTICLES[article])
        }
    }
}
