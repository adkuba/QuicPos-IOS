//
//  PostCard.swift
//  QuicPos
//
//  Created by Kuba on 18/11/2020.
//

import SwiftUI

struct PostCard: View {
    
    var post: Post
    var metrics: CGSize
    
    @State var userId = UserDefaults.standard.integer(forKey: "userId")
    @State @ObservedObject var imageLoader = ImageLoader(urlString: "")
    @State var image:UIImage = UIImage()
    
    var body: some View {
        VStack{
            Spacer(minLength: 40)
            NavigationLink(
                destination: PostViewContainer(post: post),
                label: {
                    VStack{
                        Text(post.text)
                            .frame(width: metrics.width * 0.9, height: 17, alignment: .leading)
                            .foregroundColor(.primary)
                        if (post.image ?? "") != "" {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: metrics.width * 0.9, height: 150)
                                .onReceive(imageLoader.didChange) { data in
                                    self.image = UIImage(data: data) ?? UIImage()
                                }
                                .clipped()
                                .cornerRadius(5)
                                .padding(.top)
                        }
                        if userId == (post.userid ?? -1) {
                            Link("Promote post", destination: URL(string: "https://www.quicpos.com/pay/" + (post.ID ?? "error"))!)
                                .font(.system(size: 15))
                                .frame(width: metrics.width * 0.9, height: 17, alignment: .leading)
                                .padding()
                        } else {
                            Link("Statistics", destination: URL(string: "https://www.quicpos.com/stats/" + (post.ID ?? "error"))!)
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                                .frame(width: metrics.width * 0.9, height: 17, alignment: .leading)
                                .padding()
                        }
                    }
                    
                })
            Divider()
        }
        .onAppear(perform: {
            if let im = post.image, im != "" {
                self.imageLoader = ImageLoader(urlString: "https://storage.googleapis.com/quicpos-images/" + post.image!)
            }
        })
    }
}

struct PostCard_Previews: PreviewProvider {
    static var previews: some View {
        PostCard(post: Post(text: "Post"), metrics: CGSize(width: 450, height: 1600))
    }
}
