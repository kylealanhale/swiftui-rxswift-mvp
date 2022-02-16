//
//  PostsView.swift
//  BabylonDemoApp
//
//  Created by Kyle Alan Hale on 7/7/19.
//  Copyright © 2019 Kyle Alan Hale. All rights reserved.
//

import SwiftUI

struct PostsView : View {
    @ObservedObject var presenter: ProductionPostsPresenter
    
    var body: some View {
        List(presenter.items.map { ($0, Color.getRandom()) },   // Associate a random icon/background color with each post
             id: \.0.id                                         // Identify each post's list item by its ID
        ) { (post, color) in
            NavigationLink(destination: PostsDetailView(post: post, color: color)) {
                HStack {
                    Image(systemName: "bolt.horizontal.fill").foregroundColor(color)
                    Text(post.title)
                }
            }
        }
            .navigationBarTitle(Text("Posts"))
            // Show retry button when offline
            .navigationBarItems(trailing: presenter.isOffline ? Button(action: presenter.populate) { HStack {
                Image(systemName: "bolt")
                Text("Retry")
            } }.foregroundColor(.red) : nil)
    }
}

fileprivate extension Color {
    static func getRandom() -> Color {
        return Color(hue: .random(in: 0...1), saturation: 0.333, brightness: 0.666)
    }
}
