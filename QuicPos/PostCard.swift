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
    let onDelete: () -> Void
    
    @State var userId = UserDefaults.standard.string(forKey: "user")
    @State @ObservedObject var imageLoader = ImageLoader(urlString: "")
    @State var image:UIImage = UIImage()
    let data = AppValues()
    
    @State var removeMessage = ""
    @State var removeAlert = false
    
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
                            .alert(isPresented: $removeAlert, content: {
                                Alert(title: Text("Delete"), message: Text(removeMessage))
                            })
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
                        if userId == (post.userid ?? "") {
                            HStack{
                                Link("Promote", destination: URL(string: "https://www.quicpos.com/pay/" + (post.ID ?? "error"))!)
                                    .font(.system(size: 16))
                                
                                Spacer()
                                    
                                Button(action: {
                                    deletePost(postID: post.ID ?? "")
                                }, label: {
                                    HStack{
                                        Text("Delete")
                                            .font(.system(size: 16))
                                        
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(.red)
                                    }
                                })
                            }
                            .frame(width: metrics.width * 0.9, height: 17, alignment: .leading)
                            .padding()
                        } else {
                            Link("Statistics", destination: URL(string: "https://www.quicpos.com/stats/" + (post.ID ?? "error"))!)
                                .font(.system(size: 16))
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
    
    func deletePost(postID: String){
        Network.shared.apollo
            .perform(mutation: DeletePostMutation(postID: postID, userID: userId ?? "", password: data.password)) { result in
                switch result {
                case .success(let graphQLResult):
                    if let deleteConnection = graphQLResult.data?.removePost {
                        if (deleteConnection) {
                            onDelete()
                        } else {
                            self.removeMessage = "Bad delete return! Contact us to resolve the issue."
                        }
                    }
                    if let errors = graphQLResult.errors {
                        self.removeMessage = errors.map { $0.localizedDescription }.joined(separator: "\n")
                    }
                case .failure(let error):
                    self.removeMessage = error.localizedDescription
                }
                self.removeAlert = true
            }
    }
}

struct PostCard_Previews: PreviewProvider {
    static var previews: some View {
        PostCard(post: Post(text: "Post"), metrics: CGSize(width: 450, height: 1600)){}
    }
}
