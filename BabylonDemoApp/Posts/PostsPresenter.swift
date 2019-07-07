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

struct PostsListItem {
    var title: String
    var author: String
    var description: String
    var commentCount: Int
}

protocol PostsPresenter {
    init(interactor: PostsInteractor)
    var items: BehaviorRelay<[PostsListItem]> { get }
    var errorMessage: BehaviorRelay<String?> { get }
}

final class ProductionPostsPresenter: PostsPresenter {
    var items: BehaviorRelay<[PostsListItem]> = BehaviorRelay(value: [])
    var errorMessage: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    
    init(interactor: PostsInteractor) {
        self.populate(interactor: interactor)
    }
    
    private func populate(interactor: PostsInteractor) {
        interactor.getPosts()
            // Get details associated with each post, preserving order for later sorting
            .flatMap { posts in
                // Take first 1000 posts only, since this implementation lacks paging
                Observable.merge(posts.prefix(1000).enumerated().map { index, post in
                    Observable.zip(
                        Observable.just(index),
                        Observable.just(post),
                        interactor.getUser(userId: post.userId),
                        interactor.getComments(postId: post.id).map { $0.count }
                    )
                } )
                // Collect results in a new list
                .buffer(timeSpan: RxTimeInterval.seconds(Int.max), count: posts.count, scheduler: MainScheduler.instance).take(1)
                // Sort and convert to view model type
                .map { $0
                    .sorted(by: { $0.0 < $1.0 })
                    .map { (_, post, user, commentCount) in
                        PostsListItem(title: post.title, author: user.name, description: post.body, commentCount: commentCount) }
                }
            }
            .subscribe(onNext: { [weak self] items in
                self?.items.accept(items)
            }, onError: { [weak self] error in
                self?.errorMessage.accept("Could not retrieve posts")
            })
            .disposed(by: self.disposeBag)
    }

    private let disposeBag = DisposeBag()
}
