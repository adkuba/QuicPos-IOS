//
//  ImageLoader.swift
//  QuicPos
//
//  Created by Kuba on 11/10/2020.
//

import Foundation
import Combine

class ImageLoader: ObservableObject {
    var didChange = PassthroughSubject<Data, Never>()
    var data = Data() {
        didSet {
            didChange.send(data)
        }
    }

    init(urlString: String) {
        if urlString != "" {
            guard let url = URL(string: urlString) else { return } //you use guard to exit a function when a condition isn't met
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data else { return }
                DispatchQueue.main.async {
                    self.data = data
                }
            }
            task.resume()
        }
    }
}
