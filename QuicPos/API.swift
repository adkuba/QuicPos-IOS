// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

public final class CreatePostMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation CreatePost($text: String!, $userId: Int!, $image: String!) {
      createPost(input: {text: $text, userId: $userId, image: $image}) {
        __typename
        ID
        text
        userId
        shares
        views
        creationTime
        initialReview
        image
      }
    }
    """

  public let operationName: String = "CreatePost"

  public var text: String
  public var userId: Int
  public var image: String

  public init(text: String, userId: Int, image: String) {
    self.text = text
    self.userId = userId
    self.image = image
  }

  public var variables: GraphQLMap? {
    return ["text": text, "userId": userId, "image": image]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("createPost", arguments: ["input": ["text": GraphQLVariable("text"), "userId": GraphQLVariable("userId"), "image": GraphQLVariable("image")]], type: .nonNull(.object(CreatePost.selections))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(createPost: CreatePost) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "createPost": createPost.resultMap])
    }

    public var createPost: CreatePost {
      get {
        return CreatePost(unsafeResultMap: resultMap["createPost"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "createPost")
      }
    }

    public struct CreatePost: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["PostOut"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("ID", type: .nonNull(.scalar(String.self))),
          GraphQLField("text", type: .nonNull(.scalar(String.self))),
          GraphQLField("userId", type: .nonNull(.scalar(Int.self))),
          GraphQLField("shares", type: .nonNull(.scalar(Int.self))),
          GraphQLField("views", type: .nonNull(.scalar(Int.self))),
          GraphQLField("creationTime", type: .nonNull(.scalar(String.self))),
          GraphQLField("initialReview", type: .nonNull(.scalar(Bool.self))),
          GraphQLField("image", type: .nonNull(.scalar(String.self))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: String, text: String, userId: Int, shares: Int, views: Int, creationTime: String, initialReview: Bool, image: String) {
        self.init(unsafeResultMap: ["__typename": "PostOut", "ID": id, "text": text, "userId": userId, "shares": shares, "views": views, "creationTime": creationTime, "initialReview": initialReview, "image": image])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: String {
        get {
          return resultMap["ID"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "ID")
        }
      }

      public var text: String {
        get {
          return resultMap["text"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "text")
        }
      }

      public var userId: Int {
        get {
          return resultMap["userId"]! as! Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "userId")
        }
      }

      public var shares: Int {
        get {
          return resultMap["shares"]! as! Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "shares")
        }
      }

      public var views: Int {
        get {
          return resultMap["views"]! as! Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "views")
        }
      }

      public var creationTime: String {
        get {
          return resultMap["creationTime"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "creationTime")
        }
      }

      public var initialReview: Bool {
        get {
          return resultMap["initialReview"]! as! Bool
        }
        set {
          resultMap.updateValue(newValue, forKey: "initialReview")
        }
      }

      public var image: String {
        get {
          return resultMap["image"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "image")
        }
      }
    }
  }
}

public final class GetPostQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query GetPost($userID: Int!, $normalMode: Boolean!) {
      post(userId: $userID, normalMode: $normalMode) {
        __typename
        ID
        text
        userId
        shares
        views
        creationTime
        initialReview
        image
      }
    }
    """

  public let operationName: String = "GetPost"

  public var userID: Int
  public var normalMode: Bool

  public init(userID: Int, normalMode: Bool) {
    self.userID = userID
    self.normalMode = normalMode
  }

  public var variables: GraphQLMap? {
    return ["userID": userID, "normalMode": normalMode]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("post", arguments: ["userId": GraphQLVariable("userID"), "normalMode": GraphQLVariable("normalMode")], type: .nonNull(.object(Post.selections))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(post: Post) {
      self.init(unsafeResultMap: ["__typename": "Query", "post": post.resultMap])
    }

    public var post: Post {
      get {
        return Post(unsafeResultMap: resultMap["post"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "post")
      }
    }

    public struct Post: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["PostOut"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("ID", type: .nonNull(.scalar(String.self))),
          GraphQLField("text", type: .nonNull(.scalar(String.self))),
          GraphQLField("userId", type: .nonNull(.scalar(Int.self))),
          GraphQLField("shares", type: .nonNull(.scalar(Int.self))),
          GraphQLField("views", type: .nonNull(.scalar(Int.self))),
          GraphQLField("creationTime", type: .nonNull(.scalar(String.self))),
          GraphQLField("initialReview", type: .nonNull(.scalar(Bool.self))),
          GraphQLField("image", type: .nonNull(.scalar(String.self))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: String, text: String, userId: Int, shares: Int, views: Int, creationTime: String, initialReview: Bool, image: String) {
        self.init(unsafeResultMap: ["__typename": "PostOut", "ID": id, "text": text, "userId": userId, "shares": shares, "views": views, "creationTime": creationTime, "initialReview": initialReview, "image": image])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: String {
        get {
          return resultMap["ID"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "ID")
        }
      }

      public var text: String {
        get {
          return resultMap["text"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "text")
        }
      }

      public var userId: Int {
        get {
          return resultMap["userId"]! as! Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "userId")
        }
      }

      public var shares: Int {
        get {
          return resultMap["shares"]! as! Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "shares")
        }
      }

      public var views: Int {
        get {
          return resultMap["views"]! as! Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "views")
        }
      }

      public var creationTime: String {
        get {
          return resultMap["creationTime"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "creationTime")
        }
      }

      public var initialReview: Bool {
        get {
          return resultMap["initialReview"]! as! Bool
        }
        set {
          resultMap.updateValue(newValue, forKey: "initialReview")
        }
      }

      public var image: String {
        get {
          return resultMap["image"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "image")
        }
      }
    }
  }
}

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
        GraphQLField("createUser", type: .nonNull(.scalar(Int.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(createUser: Int) {
      self.init(unsafeResultMap: ["__typename": "Query", "createUser": createUser])
    }

    public var createUser: Int {
      get {
        return resultMap["createUser"]! as! Int
      }
      set {
        resultMap.updateValue(newValue, forKey: "createUser")
      }
    }
  }
}

public final class ReportMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation Report($userID: Int!, $postID: String!) {
      report(input: {userID: $userID, postID: $postID})
    }
    """

  public let operationName: String = "Report"

  public var userID: Int
  public var postID: String

  public init(userID: Int, postID: String) {
    self.userID = userID
    self.postID = postID
  }

  public var variables: GraphQLMap? {
    return ["userID": userID, "postID": postID]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("report", arguments: ["input": ["userID": GraphQLVariable("userID"), "postID": GraphQLVariable("postID")]], type: .nonNull(.scalar(Bool.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(report: Bool) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "report": report])
    }

    public var report: Bool {
      get {
        return resultMap["report"]! as! Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "report")
      }
    }
  }
}

public final class ShareMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation Share($userID: Int!, $postID: String!) {
      share(input: {userID: $userID, postID: $postID})
    }
    """

  public let operationName: String = "Share"

  public var userID: Int
  public var postID: String

  public init(userID: Int, postID: String) {
    self.userID = userID
    self.postID = postID
  }

  public var variables: GraphQLMap? {
    return ["userID": userID, "postID": postID]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("share", arguments: ["input": ["userID": GraphQLVariable("userID"), "postID": GraphQLVariable("postID")]], type: .nonNull(.scalar(Bool.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(share: Bool) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "share": share])
    }

    public var share: Bool {
      get {
        return resultMap["share"]! as! Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "share")
      }
    }
  }
}

public final class ViewMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation View($userID: Int!, $postID: String!, $time: Float!, $device: Int!) {
      view(input: {postID: $postID, userId: $userID, time: $time, deviceDetails: $device})
    }
    """

  public let operationName: String = "View"

  public var userID: Int
  public var postID: String
  public var time: Double
  public var device: Int

  public init(userID: Int, postID: String, time: Double, device: Int) {
    self.userID = userID
    self.postID = postID
    self.time = time
    self.device = device
  }

  public var variables: GraphQLMap? {
    return ["userID": userID, "postID": postID, "time": time, "device": device]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("view", arguments: ["input": ["postID": GraphQLVariable("postID"), "userId": GraphQLVariable("userID"), "time": GraphQLVariable("time"), "deviceDetails": GraphQLVariable("device")]], type: .nonNull(.scalar(Bool.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(view: Bool) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "view": view])
    }

    public var view: Bool {
      get {
        return resultMap["view"]! as! Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "view")
      }
    }
  }
}
