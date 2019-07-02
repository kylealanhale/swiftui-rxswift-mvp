//
//  PostsModel.swift
//  BabylonDemoApp
//
//  Created by Kyle Alan Hale on 6/30/19.
//  Copyright © 2019 Kyle Alan Hale. All rights reserved.
//

import Foundation
import RxSwift

struct Post {
    var id: Int
    var userId: Int
    var title: String
    var body: String
}

struct Comment {
    var id: Int
    var postId: Int
    var email: String
    var name: String
    var body: String
}

struct User {
    var id: Int
    var name: String
    var username: String
    var email: String
}

protocol PostsInteractor {
    func getPosts() -> Observable<[Post]>
    func getComments(postId: Int) -> Observable<[Comment]>
    func getUser(userId: Int) -> Observable<User>
}
