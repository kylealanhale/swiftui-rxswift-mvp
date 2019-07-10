# RxSwift-to-SwiftUI MVP Demo App

While it may be ideal to have an end-to-end [RxSwift](https://github.com/ReactiveX/RxSwift) or [Combine](https://developer.apple.com/documentation/combine) solution, many iOS projects that currently use RxSwift will want to begin taking advantage of [SwiftUI](https://developer.apple.com/documentation/swiftui) without refactoring all their RxSwift code. This app gives an example of how such a transition can be handled.

## Setup

Requires Xcode 11.

Open the PostsApp project and wait for the dependencies to download before running the PostsApp target to launch the app. It will load a list of [jsonplaceholder](http://jsonplaceholder.typicode.com/) posts, which will be persisted for offline access. If the app is launched for the first time while offline a "Retry" button will be shown.

There is also a test target that exercises the presenter's RxSwift code for aggregating the posts list data, as described below.

## Architecture
Making the transition to using SwiftUI turns out to be a fairly simple process if you're already using [SOLID](https://en.wikipedia.org/wiki/SOLID) and [clean coding](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html) principles. This demo app was written using an [MVP](https://martinfowler.com/eaaDev/uiArchs.html#Model-view-presentermvp) pattern which follows those principles.

Additional work may be needed for different projects to get to the point where they can drop in SwiftUI views. For example, you may need to remove any references to the view concern from within your presenters, or pull any networking/database logic that is currently in view controllers into presenters and models instead. To help with that, I'll review this app's architectural approach.

### Model
Simple [`Codable`](https://developer.apple.com/documentation/foundation/archives_and_serialization/encoding_and_decoding_custom_types) data structs are exposed via the `PostsInteractor` use case protocol, which is implemented by `ProductionPostsInteractor`. This implementation uses the RxSwift extension on URLSession to return the request and JSON decoder as an observable.

Persistence is implemented via URLSession's built-in caching mechanism; if a more elaborate persistence method like a local database were needed it would be handled here. Regardless of which method is used, the consumer of a model interactor shouldn't need to know where the data is coming from, whether local or network.

### View
With SwiftUI we now have an entirely declarative view layer with data binding mechanisms, which is very exciting. More on that below, but a couple of notes on how I've implemented the views here.

First, even though this app has only one feature, the Posts list, most apps have multiple features, and the app should be structured in a way that allows these high-level feature views to be reused, moved around, or otherwise refactored. Here that means having a separate `SceneView` that hosts our `PostsView` within a `NavigationView`. This is also where dependency injection for the feature is currently happening.

Also, local state isn't limited to what is stored via `@State` properties, which may not be a good fit for all local state scenarios. For example, here I wanted to create a random color used for the icon of each post list item and detail view background. This needed to happen within the `List` loop of `PostsView`, but since SwiftUI view code is declarative I couldn't just store it to a local constant for reuse in both places. Instead I mapped each post to a tuple of itself and the color, so that the color was available to all downstream operations.

### Presenter
`PostsPresenter` is responsible for aggregating the requests of all the posts and their details using RxSwift operators, converting them to the simpler `PostsListItem` data struct, subscribing to the resulting observable, and then exposing the processed data for the view to bind to. Previously this meant binding the RxCocoa extensions to the exposed observables, but here I'm using SwiftUI's binding mechanisms instead.

Using Martin Fowler's distinctions, `PostsPresenter` is a [Presentation Model](https://martinfowler.com/eaaDev/PresentationModel.html) (as is [MVVM](https://blogs.msdn.microsoft.com/johngossman/2005/10/08/introduction-to-modelviewviewmodel-pattern-for-building-wpf-apps/)'s ViewModel, and as opposed to [VIPER](https://www.objc.io/issues/13-architecture/viper/)'s use of a [Passive View](https://martinfowler.com/eaaDev/PassiveScreen.html)). This means that the presenter logic can operate completely independently of any reference to the view layer, and that the model dependencies can be injected as simple [test stubs](https://martinfowler.com/articles/mocksArentStubs.html). The test target of this project does so by passing in a `TestPostsInteractor` implementation which provides stubbed data for the presenter to process.

As an additional benefit, the decoupling from the view layer that the Presentation Model variant of MVP gives us makes it very easy to drop in a new UI with minimal changes to the presenter. Specifically, the other variants of MVP keep the data sync logic (such as data binding) in the presenter, which then needs to be rewritten if a new view technology is chosen. Here, we only need to update the data contract between the two and let the view continue to take care of the syncing.

## RxSwift → Combine → SwiftUI
Once you're using the architectural principles described above, connecting a SwiftUI view is fairly easy. SwiftUI's documented means of binding to an external source of data is to mark a variable with the `@ObjectBinding` property wrapper, as I've done in `PostsView`:

```swift
    @ObjectBinding var presenter: ProductionPostsPresenter
```

This requires that the type of the object conform to `BindableObject`, which requires that `didChange` is implemented as one of Combine's subject types, which I've done in `ProductionPostsPresenter`:

```swift
    var didChange = PassthroughSubject<Void, Never>()
```

While I previously had my data properties exposed as RxSwift variables/relays, I changed them to normal properties storing the data in question. Then, to finish the connection, I used my RxSwift subscription handler to update the stored data and let SwiftUI's subscription to my object know of the change:

```swift
    interactor.getPosts()
        //...
        .subscribe(onNext: { [weak self] items in
            self?.items = items
            self?.isOffline = false
            self?.didChange.send()
        }, onError: { [weak self] error in
            self?.isOffline = true
            self?.didChange.send()
        })
        //...
```

A custom RxSwift operator could be written to drive the Combine publisher directly, and I'm sure people will find many clever ways to do that. (Perhaps, for example, something involving [this](https://github.com/freak4pc/RxCombine).) However, doing it this way is both simple and explicit, which is a good place to start.

## Next steps
I'm very open to suggestions and pull requests for improvements. For example:
 
* Can individual RxSwift `BehaviorRelay`s be exposed as Combine Subjects to SwiftUI in a seamless way?
* If so, is `BindableObject` better or worse than individual Subjects/Publishers?
* There seems to be a SwiftUI bug, as mentioned in a comment in `PostsDetailView`
