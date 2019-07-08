//
//  ContentView.swift
//  BabylonDemoApp
//
//  Created by Kyle Alan Hale on 6/27/19.
//  Copyright © 2019 Kyle Alan Hale. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            PostsView(posts: [
                PostsListItem(id: 0, title: "A post", author: "Some Author", description: "Hey there, it's a post", commentCount: 1)])
        }
    }
}
