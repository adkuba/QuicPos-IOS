// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

public final class GetUserQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query GetUser {
      createUser
    }
    """

  public let operationName: String = "GetUser"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("createUser", type: .nonNull(.scalar(String.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(createUser: String) {
      self.init(unsafeResultMap: ["__typename": "Query", "createUser": createUser])
    }

    public var createUser: String {
      get {
        return resultMap["createUser"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "createUser")
      }
    }
  }
}
