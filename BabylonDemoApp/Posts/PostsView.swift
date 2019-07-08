//
//  PostsView.swift
//  BabylonDemoApp
//
//  Created by Kyle Alan Hale on 7/7/19.
//  Copyright © 2019 Kyle Alan Hale. All rights reserved.
//

import SwiftUI

struct PostsView : View {
    var posts: [PostsListItem]
    
    var body: some View {
        List(posts.map { ($0, Color.getRandomDark()) }.identified(by: \.0.id)) { (post, color) in
            NavigationButton(destination: PostsDetailView(post: post, color: color)) {
                HStack {
                    Image(systemName: "bolt.horizontal.fill").foregroundColor(color)
                    Text(post.title)
                }
            }
        }
        .navigationBarTitle(Text("Posts"))
    }
}



private extension Color {
    static func getRandomDark() -> Color {
        let range = 0.3...0.6
        return Color(red: .random(in: range), green: .random(in: range), blue: .random(in: range))
    }
}
