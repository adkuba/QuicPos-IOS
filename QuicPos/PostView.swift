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
    var nextImage: String?
}

struct PostView: View {
    
    var post: Post
    var metrics: CGSize
    var selectedMode: String
    
    @State @ObservedObject var imageLoader = ImageLoader(urlString: "")
    @State @ObservedObject var nextImageLoader = ImageLoader(urlString: "")
    @State var image:UIImage = UIImage()
    @State var nextImage: UIImage = UIImage()
    @State var displayImage = false
    @State var timer = Timer.publish(every: 0.6, on: .main, in: .common).autoconnect()
    @State var blurValue = CGFloat(0)

    var body: some View {
        ZStack{
            Rectangle().frame(minWidth: metrics.width * 0.9, minHeight: 100, alignment: .center)
                .foregroundColor(
                    selectedMode == "NORMAL" ? Color(red: 27 / 255, green: 28 / 255, blue: 30 / 255) : Color.black)
                .animation(.easeIn)
                .cornerRadius(10)
            VStack{
                Text(post.text).foregroundColor(Color.white)
                    .padding()
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(width: metrics.width * 0.85, height: 70, alignment: .leading)
                
                if displayImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: metrics.width * 0.85, height: 150)
                        .onReceive(imageLoader.didChange) { data in
                            self.image = UIImage(data: data) ?? UIImage()
                        }
                        .clipped()
                }
                
                Text("20.10.2020 11:45")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .padding()
                    .frame(width: metrics.width * 0.85, height: 17, alignment: .leading)
                
                Text("0 views 0 reports")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .padding()
                    .frame(width: metrics.width * 0.85, height: 17, alignment: .leading)
                
                HStack{
                    Button(action: {}, label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 22))
                    })
                    .offset(x: 0, y: -4)
                    
                    Button(action: {}, label: {
                        Image(systemName: "exclamationmark.bubble")
                            .font(.system(size: 22))
                    })
                    .offset(x: 20, y: 0)
                }
                .padding()
                .frame(width: metrics.width * 0.85, height: 50, alignment: .leading)
            }
        }
        .fixedSize()
        .onChange(of: post.nextImage, perform: { value in
            if let im = value, im != ""{
                nextImageLoader = ImageLoader(urlString: "https://storage.googleapis.com/quicpos-images/" + im)
            }
        })
        .onReceive(nextImageLoader.didChange) { data in
            self.nextImage = UIImage(data: data) ?? UIImage()
        }
        .onChange(of: post.image, perform: { value in
            //system ladowania nastepnego zdjęcia
            //nie jest w 100% optymalne bo przechowuje 2 zdj w pamięci pierwszego posta
            //jeśli mamy jakieś następne zdj to je wykorzystujemy
            if (post.nextImage ?? "") != "" {
                self.displayImage = true
                self.image = self.nextImage
            } else {
                //nie mamy następnego zdj, sprawdzamy czy obecne zdj istnieje
                initNewImage(image: value)
            }
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
            //jesli istnieje ladujemy je - wazna dla posta w tle
            self.displayImage = true
            self.imageLoader = ImageLoader(urlString: "https://storage.googleapis.com/quicpos-images/" + image!)
        } else {
            //jesli nie mamy zadnego zdj to nie wyswietlamy
            self.displayImage = false
        }
    }
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostView(post: Post(text: "Post"), metrics: CGSize(width: 450, height: 1600), selectedMode: "NORMAL")
    }
}
