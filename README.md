# SwiftUI Nav Controller

SwiftUINavController is a wrapper around SwiftUI's `NavigationStack` that
provides helpers `push(route)`, `pop()`, `replace(routes)`.

It handles some weird cases in which `NavigationStack` breaks. It does not use
`sleep`. It waits for `onAppear`, `onDisappear` and patches `NavigationStack`'s
`UINavigationController`'s `delegate` to get access to
`navigationControllerDidShow`.

The library has been tested on iOS 16.4 and iOS 17.0.

## Example usage

```swift
import SwiftUI
import SwiftUINavController

enum ExampleRoute: Hashable, Equatable {
    case root
    case route1(id: String)
    case route2
}

typealias ExampleNavController = NavController<ExampleRoute>

struct ContentView: View {
    @State var navController = ExampleNavControllerExampleNavController(rootRoute: .root)

    var body: some View {
        Navigation(navController: navController) { _, routeContainer in
            switch routeContainer.route {
            case .root:
                AnyView(RootView())
            case .route1(let id):
                AnyView(Route1View(id: id))
            case .route2:
                AnyView(Route2View())
            }
        }
        .environmentObject(container.navController)
    }
}

struct RootView: View {
    @EnvironmentObject var navController: ExampleNavController

    var body: some View {
        Text("Root").padding()

        Button("Push 1") {
            navController.push(.route1(autoPop: false))
        }.padding()
    }
}

struct Route1View: View {
    @EnvironmentObject var navController: ExampleNavController

    var body: some View {
        Text("Route 1").padding()

        Button("Push 2") {
            navController.push(.route2)
        }.padding()

        Button("Pop") {
            navController.pop()
        }.padding()
    }
}

struct Route2View: View {
    @EnvironmentObject var navController: ExampleNavController

    var body: some View {
        Text("Route 2").padding()

        Button("Pop") {
            navController.pop()
        }.padding()
    }
}
```

## Development

### Run unit tests

```sh
xcodebuild test -scheme SwiftUINavController -destination "platform=iOS Simulator,name=iPhone 15 Pro"
```

### Run UI tests

```sh
cd SwiftUINavControllerExample
xcodebuild test -scheme SwiftUINavControllerExample -destination "platform=iOS Simulator,name=iPhone 15 Pro"
```

### Format code

```sh
swift-format --in-place --recursive .
```
