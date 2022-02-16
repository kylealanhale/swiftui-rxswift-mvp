//
//  PostsPresenter.swift
//  BabylonDemoApp
//
//  Created by Kyle Alan Hale on 6/30/19.
//  Copyright © 2019 Kyle Alan Hale. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import SwiftUI
import Combine

struct PostsListItem {
    var id: Int
    var title: String
    var author: String
    var description: String
    var commentCount: Int
}

protocol PostsPresenter {
    init(interactor: PostsInteractor)
    var items: [PostsListItem] { get }
    var isOffline: Bool { get }
}

final class ProductionPostsPresenter: PostsPresenter, ObservableObject {
    @Published var items: [PostsListItem] = []
    @Published var isOffline: Bool = false
    
    private let interactor: PostsInteractor
    
    init(interactor: PostsInteractor) {
        self.interactor = interactor
        self.populate()
    }
    
    // Populate list of items from RxSwift model and let SwiftUI view know about it
    internal func populate() {
        interactor.getPosts()
            .flatMap { posts in self.mergeDetails(posts) }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] items in
                self?.items = items
                self?.isOffline = false
            }, onError: { [weak self] error in
                self?.isOffline = true
            })
            .disposed(by: self.disposeBag)
    }
    
    private let disposeBag = DisposeBag()

    // Get details associated with each post, preserving order for later sorting
    private func mergeDetails(_ posts: [Post]) -> Observable<[PostsListItem]> {
        // Take first 100 posts only in case API changes, since demo implementation lacks paging
        let posts = posts.prefix(100)
        let bufferScheduler = SerialDispatchQueueScheduler(qos: .userInitiated)

        return Observable.merge(posts.enumerated().map { index, post in
            // Get the user and comments for each post
            Observable.zip(
                Observable.just(index),
                Observable.just(post),
                interactor.getUser(userId: post.userId),
                interactor.getComments(postId: post.id).map { $0.count }
            )
        })
        // Collect results in a new list
        .buffer(timeSpan: RxTimeInterval.seconds(Int.max), count: posts.count, scheduler: bufferScheduler).take(1)
        // Sort and convert to view model type
        .map { $0
            .sorted(by: { $0.0 < $1.0 })
            .map { (_, post, user, commentCount) in
                PostsListItem(id: post.id, title: post.title, author: user.name, description: post.body, commentCount: commentCount) }
        }
    }
}
