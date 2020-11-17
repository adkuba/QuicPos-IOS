//
//  PostView.swift
//  QuicPos
//
//  Created by Kuba on 06/10/2020.
//

import SwiftUI

struct Post {
    var ID: String?
    var text: String
    var image: String?
    var shares: Int?
    var views: Int?
    var creationTime: String?
    var loading: Bool?
    var nextImage: String?
}

struct PostView: View {
    
    var post: Post
    var metrics: CGSize
    var selectedMode: String
    
    @State var userId = UserDefaults.standard.integer(forKey: "userId")
    @State @ObservedObject var imageLoader = ImageLoader(urlString: "")
    @State @ObservedObject var nextImageLoader = ImageLoader(urlString: "")
    @State var image:UIImage = UIImage()
    @State var nextImage: UIImage = UIImage()
    @State var displayImage = false
    @State var timer = Timer.publish(every: 0.6, on: .main, in: .common).autoconnect()
    @State var blurValue = CGFloat(0)
    
    @State var shareErrorMessage = ""
    @State var shareAlertShow = false
    @State var reportConfirmationAlertShow = false
    @State var reportMessage = ""
    @State var reportAlertShow = false

    var body: some View {
        ScrollView{
            VStack{
                //text
                Text(post.text)
                    .lineLimit(nil)
                    .frame(width: metrics.width * 0.9, alignment: .leading)
                    .padding()
                    
                //image
                if displayImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: metrics.width * 0.9)
                        .onReceive(imageLoader.didChange) { data in
                            self.image = UIImage(data: data) ?? UIImage()
                        }
                        .clipped()
                        .cornerRadius(5)
                        .padding(.vertical)
                }
                
                //stats
                Text((post.creationTime ?? "20.10.2020 11:45").prefix(16))
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .padding(.vertical)
                    .frame(width: metrics.width * 0.9, height: 17, alignment: .leading)
        
                Text(String(post.views ?? 0) + " views " + String(post.shares ?? 0) + " shares")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .padding(.vertical)
                    .frame(width: metrics.width * 0.9, height: 17, alignment: .leading)
                    
                //action section
                HStack{
                    Button(action: {
                        //share
                        reportShare()
                    }, label: {
                        HStack{
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 22))
                            Text("Share")
                                .fontWeight(.semibold)
                                .offset(x:0, y:4)
                        }
                    })
                    .offset(x: 0, y: -4)
                    .alert(isPresented: $shareAlertShow, content: {
                        Alert(title: Text("Error"), message: Text(shareErrorMessage))
                    })
                        
                    Button(action: {
                        self.reportConfirmationAlertShow = true
                        self.reportAlertShow = false
                    }, label: {
                        HStack{
                            Image(systemName: "exclamationmark.bubble")
                                .font(.system(size: 22))
                            Text("Report")
                                .fontWeight(.semibold)
                        }
                    })
                    .offset(x: 20, y: 0)
                    .alert(isPresented: $reportConfirmationAlertShow, content: {
                        if (reportAlertShow){
                            return Alert(title: Text("Report"), message: Text(reportMessage))
                        } else {
                            return Alert(
                                title: Text("Are you sure?"),
                                message: Text("Do you really want to report this post?"),
                                primaryButton: .destructive(Text("Yes"), action: reportPost),
                                secondaryButton: .cancel(Text("No"))
                            )
                        }
                    })
                }
                .frame(width: metrics.width * 0.9, height: 40, alignment: .leading)
                .padding(.vertical)
            }
        }
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
    
    func reportPost(){
        if (post.ID != nil){
            let objectID = post.ID!.components(separatedBy: "\"")
            Network.shared.apollo
                .perform(mutation: ReportMutation(userID: userId, postID: objectID[1])) { result in
                    switch result {
                    case .success(let graphQLResult):
                        if let reportConnection = graphQLResult.data?.report {
                            if (reportConnection) {
                                self.reportMessage = "Thank you! Our team will review this post."
                            } else {
                                self.reportMessage = "Bad report return! Contact us to resolve the issue."
                            }
                        }
                        if let errors = graphQLResult.errors {
                            self.reportMessage = errors.map { $0.localizedDescription }.joined(separator: "\n")
                        }
                    case .failure(let error):
                        self.reportMessage = error.localizedDescription
                    }
                    self.reportAlertShow = true
                    self.reportConfirmationAlertShow = true
                }
        }
    }
    
    func reportShare(){
        var errorMessage = ""
        if (post.ID != nil){
            let objectID = post.ID!.components(separatedBy: "\"")
            let url = "https://www.quicpos.com/post/" + objectID[1]
            Network.shared.apollo
                .perform(mutation: ShareMutation(userID: userId, postID: objectID[1])) { result in
                    switch result {
                    case .success(let graphQLResult):
                        if let shareConnection = graphQLResult.data?.share {
                            if (shareConnection) {
                                let data = URL(string: url)!
                                let av = UIActivityViewController(activityItems: [data], applicationActivities: nil)
                                UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
                            } else {
                                errorMessage = "Bad share report return! Contact us to resolve the issue."
                            }
                        }
                        if let errors = graphQLResult.errors {
                            errorMessage = errors.map { $0.localizedDescription }.joined(separator: "\n")
                        }
                    case .failure(let error):
                        errorMessage = error.localizedDescription
                    }
                    if (errorMessage != ""){
                        self.shareErrorMessage = errorMessage
                        self.shareAlertShow = true
                    }
                }
        }
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
