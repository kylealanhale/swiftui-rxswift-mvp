//
//  PostsPresenterTests.swift
//  BabylonDemoAppTests
//
//  Created by Kyle Alan Hale on 6/30/19.
//  Copyright © 2019 Kyle Alan Hale. All rights reserved.
//

import XCTest
import RxSwift

@testable import PostsApp

class PostsPresenterTests: XCTestCase {
    func testItemsUpdates() {
        let interactor = TestPostsInteractor(
            posts: [Post(id: 0, userId: 0, title: "Post", body: "Post body")],
            users: [User(id: 0, name: "User", username: "username", email: "user@server.com")]
        )
        
        let presenter = ProductionPostsPresenter(interactor: interactor)
        let expectation = XCTestExpectation(description: "emitting new items")
        
        XCTAssertEqual(0, presenter.items.count)
        _ = presenter.didChange.sink {
            XCTAssertEqual(1, presenter.items.count)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testItemPopulation() {
        let expectedTitle = "Post title"
        let expectedAuthor = "Some User"
        let expectedDescription = "Post body"
        let expectedCommentCount = 2
        
        let interactor = TestPostsInteractor(
            posts: [Post(id: 0, userId: 0, title: expectedTitle, body: expectedDescription)],
            comments: [
                Comment(id: 0, postId: 0, email: "commenter1@server.com", name: "Comment", body: "Comment body"),
                Comment(id: 1, postId: 0, email: "commenter2@server.com", name: "Comment", body: "Comment body")
            ],
            users: [User(id: 0, name: expectedAuthor, username: "username", email: "user@server.com")]
        )
        
        let presenter = ProductionPostsPresenter(interactor: interactor)
        let expectation = XCTestExpectation(description: "emitting new items")
        _ = presenter.didChange.sink {
            let items = presenter.items
            XCTAssertEqual(1, items.count)
            XCTAssertEqual(expectedTitle, items[0].title)
            XCTAssertEqual(expectedAuthor, items[0].author)
            XCTAssertEqual(expectedDescription, items[0].description)
            XCTAssertEqual(expectedCommentCount, items[0].commentCount)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }

    func testMultipleItems() {
        let expectedAuthor1 = "Some User"
        let expectedAuthor2 = "Another User"
        
        let interactor = TestPostsInteractor(
            posts: [
                Post(id: 0, userId: 0, title: "Post title", body: "Post body"),
                Post(id: 1, userId: 1, title: "Post title", body: "Post body")
            ],
            comments: [
                Comment(id: 0, postId: 0, email: "commenter1@server.com", name: "Comment", body: "Comment body"),
                Comment(id: 1, postId: 1, email: "commenter2@server.com", name: "Comment", body: "Comment body"),
                Comment(id: 2, postId: 0, email: "commenter2@server.com", name: "Comment", body: "Comment body")
            ],
            users: [
                User(id: 0, name: expectedAuthor1, username: "username", email: "user@server.com"),
                User(id: 1, name: expectedAuthor2, username: "username2", email: "user2@server.com")
            ]
        )
        
        let presenter = ProductionPostsPresenter(interactor: interactor)
        let expectation = XCTestExpectation(description: "emitting new items")
        _ = presenter.didChange.sink {
            let items = presenter.items
            XCTAssertEqual(2, items.count)
            XCTAssertEqual(2, items[0].commentCount)
            XCTAssertEqual(1, items[1].commentCount)
            XCTAssertEqual(expectedAuthor1, items[0].author)
            XCTAssertEqual(expectedAuthor2, items[1].author)

            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
}

struct TestPostsInteractor: PostsInteractor {
    let posts: [Post]
    let comments: [Int: [Comment]]
    let users: [Int: User]
    
    init(posts: [Post] = [], comments: [Comment] = [], users: [User] = []) {
        self.posts = posts
        self.comments = Dictionary(grouping: comments, by: { $0.postId })
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
