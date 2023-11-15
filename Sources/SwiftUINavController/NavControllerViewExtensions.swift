import SwiftUI

extension View {
    public func navigationStackNavController<Route: Hashable>(_ navController: NavController<Route>)
        -> some View
    {
        navigationStackInfo(didShow: {
            navController.navigationControllerDidShow()
        })
    }
}
