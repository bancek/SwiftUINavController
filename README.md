# SwiftUI Nav Controller

SwiftUINavController is a wrapper around SwiftUI's `NavigationStack` that
provides helpers `push(route)`, `pop()`, `replace(routes)`.

It handles some weird cases in which `NavigationStack` breaks. It does not use
`sleep`. It waits for `onAppear`, `onDisappear` and patches `NavigationStack`'s
`UINavigationController`'s `delegate` to get access to
`navigationControllerDidShow`.

The library has been tested on iOS 16.4, iOS 17.0, iOS 18.6 and iOS 26.2.

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
    @State var navController = ExampleNavController(rootRoute: .root)

    var body: some View {
        Navigation(navController: navController) { _, routeContainer in
            Group {
                switch routeContainer.route {
                case .root:
                    RootView()
                case .route1(let id):
                    Route1View(id: id)
                case .route2:
                    Route2View()
                }
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
xcodebuild test -scheme SwiftUINavController -destination "platform=iOS Simulator,name=iPhone 17 Pro"
```

### Run UI tests

```sh
cd SwiftUINavControllerExample
xcodebuild test -scheme SwiftUINavControllerExample -destination "platform=iOS Simulator,name=iPhone 17 Pro"
```

### Format code

```sh
swift-format --in-place --recursive .
```
