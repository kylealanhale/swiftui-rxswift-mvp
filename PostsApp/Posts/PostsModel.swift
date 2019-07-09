//
//  PostsModel.swift
//  BabylonDemoApp
//
//  Created by Kyle Alan Hale on 6/30/19.
//  Copyright © 2019 Kyle Alan Hale. All rights reserved.
//

import Foundation
import RxSwift

struct Post: Codable {
    var id: Int
    var userId: Int
    var title: String
    var body: String
}

struct Comment: Codable {
    var id: Int
    var postId: Int
    var email: String
    var name: String
    var body: String
}

struct User: Codable {
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

struct ProductionPostsInteractor: PostsInteractor {
    func getComments(postId: Int) -> Observable<[Comment]> {
        return getData(url: "https://jsonplaceholder.typicode.com/comments?postId=\(postId)", type: [Comment].self)
    }
    
    func getUser(userId: Int) -> Observable<User> {
        return getData(url: "https://jsonplaceholder.typicode.com/users/\(userId)", type: User.self)
    }
    
    func getPosts() -> Observable<[Post]> {
        return getData(url: "https://jsonplaceholder.typicode.com/posts", type: [Post].self)
    }
    
    private func getData<T: Codable>(url: String, type: T.Type) -> Observable<T> {
        guard let url = URL(string: url) else {
            return Observable.error(URLError(URLError.Code.badURL))
        }
        
        var request = URLRequest(url: url)
        request.cachePolicy = URLRequest.CachePolicy.returnCacheDataElseLoad // Use cache for temporary persistence
        
        return URLSession.shared.rx.data(request: request)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .utility))
            .map { data in try JSONDecoder().decode(type, from: data) }
    }
}
