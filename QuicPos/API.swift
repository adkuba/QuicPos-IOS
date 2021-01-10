// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

public final class BlockUserMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation BlockUser($reqUser: String!, $blockUser: String!, $password: String!) {
      blockUser(input: {reqUser: $reqUser, blockUser: $blockUser}, password: $password)
    }
    """

  public let operationName: String = "BlockUser"

  public var reqUser: String
  public var blockUser: String
  public var password: String

  public init(reqUser: String, blockUser: String, password: String) {
    self.reqUser = reqUser
    self.blockUser = blockUser
    self.password = password
  }

  public var variables: GraphQLMap? {
    return ["reqUser": reqUser, "blockUser": blockUser, "password": password]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("blockUser", arguments: ["input": ["reqUser": GraphQLVariable("reqUser"), "blockUser": GraphQLVariable("blockUser")], "password": GraphQLVariable("password")], type: .nonNull(.scalar(Bool.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(blockUser: Bool) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "blockUser": blockUser])
    }

    public var blockUser: Bool {
      get {
        return resultMap["blockUser"]! as! Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "blockUser")
      }
    }
  }
}

public final class CreatePostMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation CreatePost($text: String!, $userId: String!, $image: String!, $password: String!) {
      createPost(input: {text: $text, userId: $userId, image: $image}, password: $password) {
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
  public var userId: String
  public var image: String
  public var password: String

  public init(text: String, userId: String, image: String, password: String) {
    self.text = text
    self.userId = userId
    self.image = image
    self.password = password
  }

  public var variables: GraphQLMap? {
    return ["text": text, "userId": userId, "image": image, "password": password]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("createPost", arguments: ["input": ["text": GraphQLVariable("text"), "userId": GraphQLVariable("userId"), "image": GraphQLVariable("image")], "password": GraphQLVariable("password")], type: .nonNull(.object(CreatePost.selections))),
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
          GraphQLField("userId", type: .nonNull(.scalar(String.self))),
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

      public init(id: String, text: String, userId: String, shares: Int, views: Int, creationTime: String, initialReview: Bool, image: String) {
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

      public var userId: String {
        get {
          return resultMap["userId"]! as! String
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

public final class DeletePostMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation DeletePost($postID: String!, $userID: String!, $password: String!) {
      removePost(input: {postID: $postID, userID: $userID}, password: $password)
    }
    """

  public let operationName: String = "DeletePost"

  public var postID: String
  public var userID: String
  public var password: String

  public init(postID: String, userID: String, password: String) {
    self.postID = postID
    self.userID = userID
    self.password = password
  }

  public var variables: GraphQLMap? {
    return ["postID": postID, "userID": userID, "password": password]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("removePost", arguments: ["input": ["postID": GraphQLVariable("postID"), "userID": GraphQLVariable("userID")], "password": GraphQLVariable("password")], type: .nonNull(.scalar(Bool.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(removePost: Bool) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "removePost": removePost])
    }

    public var removePost: Bool {
      get {
        return resultMap["removePost"]! as! Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "removePost")
      }
    }
  }
}

public final class GetPostQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query GetPost($userID: String!, $normalMode: Boolean!, $password: String!, $ad: Boolean!) {
      post(userId: $userID, normalMode: $normalMode, password: $password, ad: $ad) {
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

  public var userID: String
  public var normalMode: Bool
  public var password: String
  public var ad: Bool

  public init(userID: String, normalMode: Bool, password: String, ad: Bool) {
    self.userID = userID
    self.normalMode = normalMode
    self.password = password
    self.ad = ad
  }

  public var variables: GraphQLMap? {
    return ["userID": userID, "normalMode": normalMode, "password": password, "ad": ad]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("post", arguments: ["userId": GraphQLVariable("userID"), "normalMode": GraphQLVariable("normalMode"), "password": GraphQLVariable("password"), "ad": GraphQLVariable("ad")], type: .nonNull(.object(Post.selections))),
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
          GraphQLField("userId", type: .nonNull(.scalar(String.self))),
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

      public init(id: String, text: String, userId: String, shares: Int, views: Int, creationTime: String, initialReview: Bool, image: String) {
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

      public var userId: String {
        get {
          return resultMap["userId"]! as! String
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
    query GetUser($password: String!) {
      createUser(password: $password)
    }
    """

  public let operationName: String = "GetUser"

  public var password: String

  public init(password: String) {
    self.password = password
  }

  public var variables: GraphQLMap? {
    return ["password": password]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("createUser", arguments: ["password": GraphQLVariable("password")], type: .nonNull(.scalar(String.self))),
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

public final class GetViewerPostQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query GetViewerPost($id: String!) {
      viewerPost(id: $id) {
        __typename
        ID
        text
        userId
        shares
        views
        creationTime
        initialReview
        image
        blocked
      }
    }
    """

  public let operationName: String = "GetViewerPost"

  public var id: String

  public init(id: String) {
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("viewerPost", arguments: ["id": GraphQLVariable("id")], type: .nonNull(.object(ViewerPost.selections))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(viewerPost: ViewerPost) {
      self.init(unsafeResultMap: ["__typename": "Query", "viewerPost": viewerPost.resultMap])
    }

    public var viewerPost: ViewerPost {
      get {
        return ViewerPost(unsafeResultMap: resultMap["viewerPost"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "viewerPost")
      }
    }

    public struct ViewerPost: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["PostOut"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("ID", type: .nonNull(.scalar(String.self))),
          GraphQLField("text", type: .nonNull(.scalar(String.self))),
          GraphQLField("userId", type: .nonNull(.scalar(String.self))),
          GraphQLField("shares", type: .nonNull(.scalar(Int.self))),
          GraphQLField("views", type: .nonNull(.scalar(Int.self))),
          GraphQLField("creationTime", type: .nonNull(.scalar(String.self))),
          GraphQLField("initialReview", type: .nonNull(.scalar(Bool.self))),
          GraphQLField("image", type: .nonNull(.scalar(String.self))),
          GraphQLField("blocked", type: .nonNull(.scalar(Bool.self))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: String, text: String, userId: String, shares: Int, views: Int, creationTime: String, initialReview: Bool, image: String, blocked: Bool) {
        self.init(unsafeResultMap: ["__typename": "PostOut", "ID": id, "text": text, "userId": userId, "shares": shares, "views": views, "creationTime": creationTime, "initialReview": initialReview, "image": image, "blocked": blocked])
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

      public var userId: String {
        get {
          return resultMap["userId"]! as! String
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

      public var blocked: Bool {
        get {
          return resultMap["blocked"]! as! Bool
        }
        set {
          resultMap.updateValue(newValue, forKey: "blocked")
        }
      }
    }
  }
}

public final class ReportMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation Report($userID: String!, $postID: String!) {
      report(input: {userID: $userID, postID: $postID})
    }
    """

  public let operationName: String = "Report"

  public var userID: String
  public var postID: String

  public init(userID: String, postID: String) {
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
    mutation Share($userID: String!, $postID: String!, $password: String!) {
      share(input: {userID: $userID, postID: $postID}, password: $password)
    }
    """

  public let operationName: String = "Share"

  public var userID: String
  public var postID: String
  public var password: String

  public init(userID: String, postID: String, password: String) {
    self.userID = userID
    self.postID = postID
    self.password = password
  }

  public var variables: GraphQLMap? {
    return ["userID": userID, "postID": postID, "password": password]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("share", arguments: ["input": ["userID": GraphQLVariable("userID"), "postID": GraphQLVariable("postID")], "password": GraphQLVariable("password")], type: .nonNull(.scalar(Bool.self))),
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
    mutation View($userID: String!, $postID: String!, $time: Float!, $device: String!, $password: String!) {
      view(input: {postID: $postID, userId: $userID, time: $time, deviceDetails: $device}, password: $password)
    }
    """

  public let operationName: String = "View"

  public var userID: String
  public var postID: String
  public var time: Double
  public var device: String
  public var password: String

  public init(userID: String, postID: String, time: Double, device: String, password: String) {
    self.userID = userID
    self.postID = postID
    self.time = time
    self.device = device
    self.password = password
  }

  public var variables: GraphQLMap? {
    return ["userID": userID, "postID": postID, "time": time, "device": device, "password": password]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("view", arguments: ["input": ["postID": GraphQLVariable("postID"), "userId": GraphQLVariable("userID"), "time": GraphQLVariable("time"), "deviceDetails": GraphQLVariable("device")], "password": GraphQLVariable("password")], type: .nonNull(.scalar(Bool.self))),
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
