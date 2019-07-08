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
            color
                .opacity(0.1)
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading) {
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
                Text(post.description)
                Spacer().layoutPriority(1)
            }
            .navigationBarTitle(Text(post.title))
            .padding()
        }
    }
}
