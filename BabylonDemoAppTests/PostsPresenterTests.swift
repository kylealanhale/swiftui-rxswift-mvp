//
//  PostsPresenterTests.swift
//  BabylonDemoAppTests
//
//  Created by Kyle Alan Hale on 6/30/19.
//  Copyright © 2019 Kyle Alan Hale. All rights reserved.
//

import XCTest
import RxSwift

@testable import BabylonDemoApp

class PostsPresenterTests: XCTestCase {
    var disposeBag = DisposeBag()

    func testItemsUpdates() {
        let interactor = TestPostsInteractor(
            posts: [Post(id: 0, userId: 0, title: "Post", body: "Post body")],
            users: [User(id: 0, name: "User", username: "username", email: "user@server.com")]
        )
        
        let presenter = ProductionPostsPresenter(interactor: interactor)
        var emissions = 0
        let expectation = XCTestExpectation(description: "emitting new items")
        presenter.items.bind { items in
            XCTAssertEqual(items.count, emissions)
            
            emissions += 1
            if emissions == 2 {
                expectation.fulfill()
            }
        }
        .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 1)
    }
}

struct TestPostsInteractor: PostsInteractor {
    let posts: [Post]
    let comments: [Int: [Comment]]
    let users: [Int: User]
    
    init(posts: [Post] = [], comments: [Int: [Comment]] = [:], users: [User] = []) {
        self.posts = posts
        self.comments = comments
        self.users = Dictionary(uniqueKeysWithValues: users.map { ($0.id, $0) })
    }
    
    func getPosts() -> Observable<[Post]> {
        return Observable.just(self.posts)
            // Simulate non-negligible disk/network time
            .delay(.milliseconds(1), scheduler: SerialDispatchQueueScheduler(qos: .background))
    }
    
    func getComments(postId: Int) -> Observable<[Comment]> {
        return Observable.just(self.comments[postId] ?? [])
    }
    
    func getUser(userId: Int) -> Observable<User> {
        guard let user = self.users[userId] else {
            return Observable.empty()
        }
        return Observable.just(user)
    }
}
