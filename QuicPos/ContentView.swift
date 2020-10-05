//
//  ContentView.swift
//  QuicPos
//
//  Created by Kuba on 03/10/2020.
//

import SwiftUI

struct ContentView: View {
    
    //state allows modification during self invoke
    @State var postText = 1
    @State var userId = UserDefaults.standard.string(forKey: "userId")
    
    @State var showingAlert = false
    @State var errorMessage = ""
    
    //DispatchGroup for async operations
    let group = DispatchGroup()
    
    var body: some View {
        GeometryReader { metrics in
            ZStack{
                Color.black
                Rectangle().frame(width: metrics.size.width * 0.85, height: 200, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    .foregroundColor(Color(red: 28 / 255, green: 28 / 255, blue: 30 / 255))
                    .cornerRadius(10)
                    .gesture(TapGesture()
                                .onEnded({ _ in
                                    self.postText += 1
                                }))
                Text("Post " + String(self.postText))
                    .foregroundColor(Color.white)
                    .padding()
            }
        }
        .onAppear(perform: {
            if self.userId == nil {
                saveUserId()
            } else {
                self.errorMessage = self.userId!
            }
            //group notify will run when enter() and leave() are balanced
            //waits for userId to be downloaded
            group.notify(queue: .main) {
                self.showingAlert = true
                print("alert showed")
            }
        })
        .alert(isPresented: $showingAlert, content: {
            Alert(title: Text("userId: "), message: Text(self.errorMessage), dismissButton: .default(Text("Got it!")))
        })
        .preferredColorScheme(.dark)
    }
    
    func saveUserId(){
        group.enter()
        //send this code to async
        DispatchQueue.main.async {
            //fetch and save data
            Network.shared.apollo
                .fetch(query: GetUserQuery()) { result in
                    switch result {
                    case .success(let graphQLResult):
                        if let userConnection = graphQLResult.data?.createUser {
                            UserDefaults.standard.setValue(userConnection, forKey: "userId")
                            self.userId = userConnection
                            self.errorMessage = userConnection
                            print("userID saved")
                        }
                        if let errors = graphQLResult.errors {
                            self.errorMessage = errors
                                .map { $0.localizedDescription }
                                .joined(separator: "\n")
                        }
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                    }
                    //notify results are downloaded
                    group.leave()
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}
