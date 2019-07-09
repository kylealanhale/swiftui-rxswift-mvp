//
//  SceneView.swift
//  BabylonDemoApp
//
//  Created by Kyle Alan Hale on 6/27/19.
//  Copyright © 2019 Kyle Alan Hale. All rights reserved.
//

import SwiftUI

struct SceneView: View {
    var body: some View {
        NavigationView {
            PostsView(presenter: ProductionPostsPresenter(interactor: ProductionPostsInteractor()))
        }
    }
}
