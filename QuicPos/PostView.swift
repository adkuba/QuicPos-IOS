//
//  PostView.swift
//  QuicPos
//
//  Created by Kuba on 06/10/2020.
//

import SwiftUI

struct Post {
    var text: String
    var image: String? //? optional field
    var loading: Bool?
}

struct PostView: View {
    
    var post: Post
    var metrics: CGSize
    
    @State @ObservedObject var imageLoader = ImageLoader(urlString: "")
    @State var image:UIImage = UIImage()
    @State var displayImage = false
    @State var timer = Timer.publish(every: 0.6, on: .main, in: .common).autoconnect()
    @State var blurValue = CGFloat(0)

    var body: some View {
        ZStack{
            Rectangle().frame(minWidth: metrics.width * 0.9, minHeight: 100, alignment: .center)
                .foregroundColor(Color(red: 50 / 255, green: 50 / 255, blue: 52 / 255))
                .cornerRadius(10)
            VStack{
                Text(post.text).foregroundColor(Color.white)
                    .padding()
                    .frame(width: metrics.width * 0.85, height: 100, alignment: .leading)
                
                if displayImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: metrics.width * 0.85, height: 150)
                        .onReceive(imageLoader.didChange) { data in
                            self.image = UIImage(data: data) ?? UIImage()
                        }
                }
            }
        }
        .fixedSize()
        .onChange(of: post.image, perform: { value in
            initNewImage(image: value)
        })
        .animation(nil)
        .blur(radius: blurValue)
        .animation(.linear(duration: 0.4))
        .onReceive(timer, perform: { time in
            if blurValue == 10 {
                self.blurValue = 0
            } else {
                self.blurValue = 10
            }
        })
        .onChange(of: post.loading, perform: { value in
            if value ?? false {
                self.timer = Timer.publish(every: 0.6, on: .main, in: .common).autoconnect()
            } else {
                self.blurValue = 0
                self.timer.upstream.connect().cancel()
            }
        })
        .onAppear(perform: {
            if !(post.loading ?? false) {
                self.blurValue = 0
                self.timer.upstream.connect().cancel()
            }
        })
    }
    
    func initNewImage(image: String?){
        if let im = image, im != "" {
            self.displayImage = true
            self.imageLoader = ImageLoader(urlString: "https://storage.googleapis.com/quicpos-images/" + image!)
        } else {
            self.displayImage = false
        }
    }
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostView(post: Post(text: "Post"), metrics: CGSize(width: 450, height: 1600))
    }
}
