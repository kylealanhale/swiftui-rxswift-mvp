//
//  PostsView.swift
//  BabylonDemoApp
//
//  Created by Kyle Alan Hale on 7/7/19.
//  Copyright © 2019 Kyle Alan Hale. All rights reserved.
//

import SwiftUI

struct PostsView : View {
    @ObjectBinding var presenter: ProductionPostsPresenter
    
    var body: some View {
        
        List(presenter
            .items
            .map { ($0, Color.getRandom()) }
            .identified(by: \.0.id)
        ) { (post, color) in
            NavigationLink(destination: PostsDetailView(post: post, color: color)) {
                HStack {
                    Image(systemName: "bolt.horizontal.fill").foregroundColor(color)
                    Text(post.title)
                }
            }
        }
            .navigationBarTitle(Text("Posts"))
            .navigationBarItems(trailing: presenter.isOffline ? Button(action: presenter.populate) { HStack {
                Image(systemName: "bolt")
                Text("Offline")
            } }.foregroundColor(.red) : nil)
    }
}



private extension Color {
    static func getRandom() -> Color {
        let range = 0.36...0.9
        return Color(red: .random(in: range), green: .random(in: range), blue: .random(in: range))
    }
}


