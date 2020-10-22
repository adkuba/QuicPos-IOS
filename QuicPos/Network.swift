//
//  Network.swift
//  QuicPos
//
//  Created by Kuba on 05/10/2020.
//

import Foundation
import Apollo


class Network {
  static let shared = Network()
    
  private(set) lazy var apollo = ApolloClient(url: URL(string: "http://api.quicpos.com/query")!)
}
