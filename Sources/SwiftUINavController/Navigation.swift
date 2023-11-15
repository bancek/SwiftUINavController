import SwiftUI

public struct Navigation<Route: Hashable, RouteBody: View>: View {
    @ObservedObject var navController: NavController<Route>
    @ViewBuilder let buildRoute: (NavController<Route>, RouteContainer<Route>) -> RouteBody

    public init(
        navController: NavController<Route>,
        buildRoute: @escaping (NavController<Route>, RouteContainer<Route>) -> RouteBody
    ) {
        self.navController = navController
        self.buildRoute = buildRoute
    }

    public var body: some View {
        NavigationStack(path: $navController.path) {
            NavView(
                navController: navController, routeContainer: navController.state.rootRouteContainer
            ) {
                buildRoute(navController, navController.state.rootRouteContainer)
            }
            .navigationDestination(
                for: RouteContainer<Route>.self,
                destination: { routeContainer in
                    NavView(navController: navController, routeContainer: routeContainer) {
                        buildRoute(navController, routeContainer)
                    }
                })
        }
        .navigationStackNavController(navController)
    }
}
