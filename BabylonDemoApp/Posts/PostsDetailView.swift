//
//  PostsDetailView.swift
//  BabylonDemoApp
//
//  Created by Kyle Alan Hale on 7/7/19.
//  Copyright © 2019 Kyle Alan Hale. All rights reserved.
//

import SwiftUI

struct PostsDetailView : View {
    var post: PostsListItem
    var color: Color
    
    var body: some View {
        ZStack {
            // Use post color to create a lighter-colored background
            color
                .opacity(0.1)
                .edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack(alignment: .leading) {
                    Text(post.title)
                        .font(.title)
                    Spacer()
                    HStack {
                        Text("by \(post.author)").font(.headline)
                        Spacer()
                        Text("\(post.commentCount) comment(s)").font(.headline)
                    }
                    HStack {
                        Spacer()
                        Image(systemName: "bolt.horizontal").padding()
                        Spacer()
                    }
                    // Repeat content to force scrolling which for some reason corrects
                    // (or improves, at least) SwiftUI layout lineLimit(nil) bug described here:
                    // https://stackoverflow.com/questions/56505929/the-text-doesnt-gets-wrap-in-swift-ui
                    Text(Array(repeating: post.description, count: 9).joined(separator: "\n\n"))
                }
                .lineLimit(nil)
                .padding()
            }
        }
        .navigationBarTitle("Post", displayMode: .inline)
    }
}

