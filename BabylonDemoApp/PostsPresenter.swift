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

    private let disposeBag = DisposeBag()
    private var hasBeenPopulated = false
    
    init(interactor: PostsInteractor) {
        items.do(onSubscribe: {
            self.populate(interactor: interactor)
        }).subscribe().disposed(by: self.disposeBag)
    }
    
    private func populate(interactor: PostsInteractor) {
        interactor.getPosts()
            // Get details associated with each post, preserving order for later sorting
            .flatMap { posts in Observable.merge(posts.enumerated().map { index, post in
                Observable.zip(
                    Observable.just(index),
                    Observable.just(post),
                    interactor.getUser(userId: post.userId),
                    interactor.getComments(postId: post.id).map { $0.count }
                )
            } )
            // Collect results in a new list
            .buffer(timeSpan: RxTimeInterval.seconds(Int.max), count: posts.count, scheduler: MainScheduler.instance)
            // Sort and convert to view model type
            .map { $0
                .sorted(by: { $0.0 < $1.0 })
                .map { (_, post, user, commentCount) in
                    PostsListItem(title: post.title, author: user.name, description: post.body, commentCount: commentCount) }
            }
        }
        .subscribe(onNext: { items in
            self.items.accept(items)
        }, onError: { error in
            self.errorMessage.accept("Could not retrieve posts")
        })
        .disposed(by: self.disposeBag)
        
        
        
//        // Observable<[Observable<PostsListItem>]>
//        let things2 = interactor.getPosts()
//            .map { posts in posts.map { post in
//                    Observable.zip(
//                        Observable.just(post),
//                        interactor.getUser(userId: post.userId),
//                        interactor.getComments(postId: post.id)
//                    )
//                    .map { (post, user, comments) in
//                        PostsListItem(title: post.title, author: user.name, description: post.body, commentCount: comments.count)}
//                }
//            }
        

        
        
//        let thing = interactor.getPosts()
//            .map { posts in
//                Observable.from(posts)
//                    .map { post in
//                        Observable.merge(
//                            interactor.getComments(postId: 0),
//                            interactor.getUser(userId: 0))
//                }
//
//            }
//        let thing = interactor.getPosts()
//            .flatMap { posts in Observable.create { observer in
//                posts.map { post in
//                    interactor.getUser(userId: post.userId)
//                        .map { user in PostsListItem(title: post.title, author: user.name, description: post.body, commentCount: 0)}
//                }
//
//            } }
//            .map { items in items.map { item in
//                interactor.getComments(postId: 0)
//                    .map { item.commentCount = $0.count; item }
//                } }
        
        
    }
}
