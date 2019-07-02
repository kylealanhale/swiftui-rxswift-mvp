//
//  PostsAPI.swift
//  BabylonDemoApp
//
//  Created by Kyle Alan Hale on 6/27/19.
//  Copyright © 2019 Kyle Alan Hale. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa



protocol PostsAPI {
    func getPosts() -> Observable<[Post]>
    func getComments(postId: Int) -> Observable<[Comment]>
    func getUser(userId: Int) -> Observable<User>
}

//struct ProductionPostsAPI: PostsAPI {
//    func getPost(postId: Int) -> Observable<Post> {
//        return URLSession.shared.rx.json(url: URL(string: "")!)
//            .map { (data) -> Post in
//                return Post() }
//    }
//
//    func getComments(postId: Int) -> Observable<[Comment]> {
//
//    }
//
//    func getUser(userId: Int) -> Observable<User> {
//
//    }
//
//    func getPosts() -> Observable<[Post]> {
//
//    }
//}
//

