import SwiftUI

struct NavView<Content, Route>: View where Content: View, Route: Hashable {
    let navController: NavController<Route>
    let routeContainer: RouteContainer<Route>
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .onAppear {
                navController.onAppear(routeContainer)
            }
            .onDisappear {
                navController.onDisappear(routeContainer)
            }
    }
}
