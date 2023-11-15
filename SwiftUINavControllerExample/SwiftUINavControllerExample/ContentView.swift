import Combine
import SwiftUI
import SwiftUINavController

enum ExampleRoute: Hashable, Equatable {
    case root
    case route1(autoPop: Bool)
    case route2
    case route3
    case route4

    var description: String {
        switch self {
        case .root: return "root"
        case .route1(let autoPop): return "route1(autoPop: \(autoPop))"
        case .route2: return "route2"
        case .route3: return "route3"
        case .route4: return "route4"
        }
    }
}

typealias ExampleNavController = NavController<ExampleRoute>

struct Container {
    let navController: ExampleNavController
    let history: History

    init() {
        navController = ExampleNavController(rootRoute: .root)
        history = History(navController: navController)

        if CommandLine.arguments.contains("push1push2") {
            navController.push(.route1(autoPop: false))
            navController.push(.route2)
        }
    }
}

struct ContentView: View {
    @State var container = Container()

    var body: some View {
        Navigation(navController: container.navController) { _, routeContainer in
            Group {
                switch routeContainer.route {
                case .root:
                    RootView()
                case .route1(let autoPop):
                    Route1View(autoPop: autoPop)
                case .route2:
                    Route2View()
                case .route3:
                    Route3View()
                case .route4:
                    Route4View()
                }
            }
        }
        .environmentObject(container.navController)
        .environmentObject(container.history)
    }
}

struct RootView: View {
    @EnvironmentObject var navController: ExampleNavController

    var body: some View {
        VStack {
            Text("Root").padding()

            Button("Push 1") {
                navController.push(.route1(autoPop: false))
            }.padding()

            Button("Push 1 (auto pop)") {
                navController.push(.route1(autoPop: true))
            }.padding()

            Button("Replace 3, 4") {
                navController.replace([.route3, .route4])
            }.padding()

            HistoryView()
        }
    }
}

struct Route1View: View {
    let autoPop: Bool

    @EnvironmentObject var navController: ExampleNavController

    var body: some View {
        VStack {
            Text("Route 1").padding()

            Button("Push 2") {
                navController.push(.route2)
            }.padding()

            Button("Pop") {
                navController.pop()
            }.padding()

            HistoryView()
        }
        .task {
            if autoPop {
                navController.pop()
            }
        }
    }
}

struct Route2View: View {
    @EnvironmentObject var navController: ExampleNavController

    var body: some View {
        VStack {
            Text("Route 2").padding()

            Button("Replace 1, 2") {
                navController.replace([.route1(autoPop: false), .route2])
            }.padding()

            Button("Replace 3, 4") {
                navController.replace([.route3, .route4])
            }.padding()

            Button("Replace 1, 3") {
                navController.replace([.route1(autoPop: false), .route3])
            }.padding()

            Button("Pop") {
                navController.pop()
            }.padding()

            HistoryView()
        }
    }
}

struct Route3View: View {
    @EnvironmentObject var navController: ExampleNavController

    var body: some View {
        VStack {
            Text("Route 3").padding()

            Button("Push 4") {
                navController.push(.route4)
            }.padding()

            Button("Pop") {
                navController.pop()
            }.padding()

            HistoryView()
        }
    }
}

struct Route4View: View {
    @EnvironmentObject var navController: ExampleNavController

    var body: some View {
        VStack {
            Text("Route 4").padding()

            Button("Pop") {
                navController.pop()
            }.padding()

            HistoryView()
        }
    }
}

class History: ObservableObject {
    let navController: ExampleNavController
    @Published var history = [String]()

    private var pathChangedCancellable: AnyCancellable?

    init(navController: ExampleNavController) {
        self.navController = navController

        self.pathChangedCancellable = navController.$path.sink { [weak self] path in
            self?.addPath(path)
        }
    }

    func addPath(_ path: [RouteContainer<ExampleRoute>]) {
        history.append("/" + path.map { $0.route.description }.joined(separator: "/"))
    }
}

struct HistoryView: View {
    @EnvironmentObject var history: History

    var body: some View {
        Text("History:\n\(history.history.joined(separator: "\n"))")
    }
}
