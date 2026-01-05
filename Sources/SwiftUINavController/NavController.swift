import Combine
import Foundation

public struct RouteContainer<Route: Equatable & Hashable>: Equatable & Hashable {
    public var id: Int
    public var route: Route

    public init(id: Int, route: Route) {
        self.id = id
        self.route = route
    }
}

public class NavController<Route: Equatable & Hashable>: ObservableObject {
    @Published public var path: [RouteContainer<Route>]
    @Published public var state: State
    public var viewModels: [Int: [String: Any]]
    private let debugEnabled: Bool

    private var pathChangedCancellable: AnyCancellable?

    public init(rootRoute: Route, debugEnabled: Bool = false) {
        self.path = []
        self.state = State(rootRoute: rootRoute)
        self.viewModels = [0: [:]]
        self.debugEnabled = debugEnabled

        self.pathChangedCancellable = self.$path.sink { [weak self] path in
            self?.pathChanged(path: path)
        }
    }

    public func push(_ route: Route) {
        log("push route: \(route)")

        state = state.withNavOpQueueChange { $0.append(.push(route: route)) }

        processNavOps()
    }

    public func pop() {
        log("pop")

        state = state.withNavOpQueueChange { $0.append(.pop) }

        processNavOps()
    }

    public func replace(_ routes: [Route]) {
        log("replace routes: \(routes)")

        state = state.withNavOpQueueChange { $0.append(.replace(routes: routes)) }

        processNavOps()
    }

    public func alertDisplayed(_ alertId: String) {
        log("alert displayed: \(alertId)")

        state = state.withVisibleAlerts(state.visibleAlerts.union([alertId]))
    }

    public func alertHidden(_ alertId: String) {
        log("alert hidden: \(alertId)")

        state = state.withVisibleAlerts(state.visibleAlerts.subtracting([alertId]))

        processNavOps()
    }

    public func ensureViewModel<T>(routeContainer: RouteContainer<Route>, create: () -> T) -> T {
        if viewModels[routeContainer.id] == nil {
            // route does not exist anymore, do not cache the view model
            return create()
        }

        let type = String(describing: T.self)

        if let vm = viewModels[routeContainer.id]![type] {
            return vm as! T
        }

        let vm = create()

        viewModels[routeContainer.id]![type] = vm

        return vm
    }

    public func onAppear(_ routeContainer: RouteContainer<Route>) {
        log("onAppear route container: \(routeContainer)")

        state = state.withRouteStateVisible(id: routeContainer.id, visible: true)

        processNavWait(navWait: .appear(id: routeContainer.id))
    }

    public func onDisappear(_ routeContainer: RouteContainer<Route>) {
        log("onDisappear route container: \(routeContainer)")

        if let routeState = state.routesState[routeContainer.id] {
            let routeState = routeState.withVisible(false)

            var routesState = state.routesState
            routesState[routeContainer.id] = routeState

            checkRouteCleanup(routesState: &routesState, id: routeContainer.id)

            state = state.withRoutesState(routesState)

            processNavWait(navWait: .disappear(id: routeContainer.id))
        }
    }

    public func navigationControllerDidShow() {
        log("did show")

        processNavWait(navWait: .navigationControllerDidShow)
    }

    private func log(_ message: String) {
        if debugEnabled {
            print("NavController: \(message)")
        }
    }

    private func buildRouteContainer(route: Route) -> RouteContainer<Route> {
        let id = state.nextId

        let routeState = RouteState(id: id, route: route, inPath: false, visible: false)

        var routesState = state.routesState

        routesState[id] = routeState

        state = state.withNextId(state.nextId + 1).withRoutesState(routesState)

        viewModels[id] = [:]

        return RouteContainer(id: id, route: route)
    }

    private func processNavOps() {
        while !state.navOpQueue.isEmpty && state.navWait.isEmpty && state.visibleAlerts.isEmpty {
            var navOpQueue = state.navOpQueue

            let navOp = navOpQueue.removeFirst()

            state = state.withNavOpQueue(navOpQueue)

            processNavOp(navOp: navOp)
        }
    }

    private func processNavOp(navOp: NavOp) {
        log("process nav op: \(navOp)")

        switch navOp {
        case .push(let route):
            processNavOpPush(route: route)
        case .pop:
            processNavOpPop()
        case .replace(let routes):
            processNavOpReplace(routes: routes)
        }
    }

    private func processNavOpPush(route: Route) {
        let routeContainer = buildRouteContainer(route: route)

        log("process nav op push route container: \(routeContainer)")

        var path = state.path
        path.append(routeContainer)

        var navWait = state.navWait

        NavWait.forPush(&navWait, oldId: state.activeRouteContainer.id, newId: routeContainer.id)

        state = state.withPath(path).withNavWait(navWait)

        self.path.append(routeContainer)
    }

    private func processNavOpPop() {
        var path = state.path

        guard let routeContainer = path.popLast() else {
            return
        }

        var navWait = state.navWait

        NavWait.forPop(&navWait, oldId: routeContainer.id)

        state = state.withPath(path).withNavWait(navWait)

        self.path.removeLast()
    }

    private func processNavOpReplace(routes: [Route]) {
        if let navOp = processNavOpReplaceNextNavOp(routes: routes) {
            var navOpQueue = state.navOpQueue
            navOpQueue.insert(.replace(routes: routes), at: 0)
            navOpQueue.insert(navOp, at: 0)

            state = state.withNavOpQueue(navOpQueue)
        }
    }

    private func processNavOpReplaceNextNavOp(routes: [Route]) -> NavOp? {
        if state.path.count > routes.count {
            return .pop
        }

        for (i, route) in routes.enumerated() {
            if i < state.path.count {
                if route != state.path[i].route {
                    return .pop
                }
            } else {
                return .push(route: route)
            }
        }

        return nil
    }

    private func processNavWait(navWait: NavWait) {
        log("process nav wait: \(navWait)")

        // we have to ignore the order of navWait
        // in iOS 16 disappear is called before navigationControllerDidShow
        // in iOS 17 disappear is after before navigationControllerDidShow
        if let idx = state.navWait.firstIndex(of: navWait) {
            var navWait = state.navWait
            navWait.remove(at: idx)

            state = state.withNavWait(navWait)

            processNavOps()
        }
    }

    private func pathChanged(path: [RouteContainer<Route>]) {
        log("path changed: \(path)")

        var pathRouteIds = Set<Int>()

        pathRouteIds.insert(0)

        for routeContainer in path {
            pathRouteIds.insert(routeContainer.id)
        }

        var routesState = state.routesState

        for id in Array(routesState.keys) {
            // update routeState.inPath
            let routeState = routesState[id]!.withInPath(pathRouteIds.contains(id))

            routesState[id] = routeState

            log("path changed route state: \(routeState)")

            // remove routeState if not inPath and not visible anymore
            checkRouteCleanup(routesState: &routesState, id: id)
        }

        var navWait = state.navWait

        // call navWaitForPop for routeStates that are visible but not in
        // state.path anymore (state.path, not path, from last to root)
        for routeContainer in state.path.reversed() {
            if let routeState = routesState[routeContainer.id] {
                if !routeState.inPath {
                    NavWait.forPop(&navWait, oldId: routeContainer.id)
                }
            }
        }

        state = state.withPath(path).withRoutesState(routesState).withNavWait(navWait)
    }

    private func checkRouteCleanup(routesState: inout [Int: RouteState], id: Int) {
        guard let routeState = routesState[id] else {
            return
        }

        if !routeState.inPath && !routeState.visible {
            log("check route cleanup remove route: \(routeState)")

            routesState.removeValue(forKey: id)

            viewModels.removeValue(forKey: id)
        }
    }

    public enum NavOp: Equatable {
        case push(route: Route)
        case pop
        case replace(routes: [Route])
    }

    public struct RouteState: Equatable {
        public let id: Int
        public let route: Route
        public let inPath: Bool
        public let visible: Bool

        public init(id: Int, route: Route, inPath: Bool, visible: Bool) {
            self.id = id
            self.route = route
            self.inPath = inPath
            self.visible = visible
        }

        public func withInPath(_ inPath: Bool) -> RouteState {
            return RouteState(id: id, route: route, inPath: inPath, visible: visible)
        }

        public func withVisible(_ visible: Bool) -> RouteState {
            return RouteState(id: id, route: route, inPath: inPath, visible: visible)
        }
    }

    public struct State: Equatable {
        public let path: [RouteContainer<Route>]
        public let rootRouteContainer: RouteContainer<Route>
        public let nextId: Int
        public let routesState: [Int: RouteState]
        public let navOpQueue: [NavOp]
        public let navWait: [NavWait]
        public let visibleAlerts: Set<String>

        public var activeRouteContainer: RouteContainer<Route> {
            path.last ?? rootRouteContainer
        }

        public var activeRoute: Route {
            activeRouteContainer.route
        }

        public var isNavigating: Bool {
            navOpQueue.count > 0 || navWait.count > 0
                || routesState.values.lazy.filter({ $0.visible }).count > 1
        }

        public init(
            path: [RouteContainer<Route>],
            rootRouteContainer: RouteContainer<Route>,
            nextId: Int,
            routesState: [Int: RouteState],
            navOpQueue: [NavOp],
            navWait: [NavWait],
            visibleAlerts: Set<String>
        ) {
            self.path = path
            self.rootRouteContainer = rootRouteContainer
            self.nextId = nextId
            self.routesState = routesState
            self.navOpQueue = navOpQueue
            self.navWait = navWait
            self.visibleAlerts = visibleAlerts
        }

        public init(rootRoute: Route) {
            let path = [RouteContainer<Route>]()

            let rootRouteContainer = RouteContainer(id: 0, route: rootRoute)

            let nextId = 1

            var routesState = [Int: RouteState]()
            routesState[rootRouteContainer.id] = RouteState(
                id: rootRouteContainer.id, route: rootRouteContainer.route, inPath: true,
                visible: false)

            let navOpQueue = [NavOp]()

            var navWait = [NavWait]()

            NavWait.forRoot(&navWait)

            let visibleAlerts = Set<String>()

            self.init(
                path: path,
                rootRouteContainer: rootRouteContainer,
                nextId: nextId,
                routesState: routesState,
                navOpQueue: navOpQueue,
                navWait: navWait,
                visibleAlerts: visibleAlerts
            )
        }

        public func withPath(_ path: [RouteContainer<Route>]) -> State {
            return State(
                path: path,
                rootRouteContainer: rootRouteContainer,
                nextId: nextId,
                routesState: routesState,
                navOpQueue: navOpQueue,
                navWait: navWait,
                visibleAlerts: visibleAlerts
            )
        }

        public func withNextId(_ nextId: Int) -> State {
            return State(
                path: path,
                rootRouteContainer: rootRouteContainer,
                nextId: nextId,
                routesState: routesState,
                navOpQueue: navOpQueue,
                navWait: navWait,
                visibleAlerts: visibleAlerts
            )
        }

        public func withRoutesState(_ routesState: [Int: RouteState]) -> State {
            return State(
                path: path,
                rootRouteContainer: rootRouteContainer,
                nextId: nextId,
                routesState: routesState,
                navOpQueue: navOpQueue,
                navWait: navWait,
                visibleAlerts: visibleAlerts
            )
        }

        public func withRouteStateChange(_ change: (inout [Int: RouteState]) -> Void) -> State {
            var routesState = routesState
            change(&routesState)
            return withRoutesState(routesState)
        }

        public func withRouteStateChange(_ id: Int, change: (RouteState) -> RouteState) -> State {
            withRouteStateChange { routesState in
                if let routeState = routesState[id] {
                    routesState[id] = change(routeState)
                }
            }
        }

        public func withRouteStateInPath(id: Int, inPath: Bool) -> State {
            return withRouteStateChange(id) { $0.withInPath(inPath) }
        }

        public func withRouteStateVisible(id: Int, visible: Bool) -> State {
            return withRouteStateChange(id) { $0.withVisible(visible) }
        }

        public func withNavOpQueue(_ navOpQueue: [NavOp]) -> State {
            return State(
                path: path,
                rootRouteContainer: rootRouteContainer,
                nextId: nextId,
                routesState: routesState,
                navOpQueue: navOpQueue,
                navWait: navWait,
                visibleAlerts: visibleAlerts
            )
        }

        public func withNavOpQueueChange(_ change: (inout [NavOp]) -> Void) -> State {
            var navOpQueue = self.navOpQueue
            change(&navOpQueue)
            return withNavOpQueue(navOpQueue)
        }

        public func withNavWait(_ navWait: [NavWait]) -> State {
            return State(
                path: path,
                rootRouteContainer: rootRouteContainer,
                nextId: nextId,
                routesState: routesState,
                navOpQueue: navOpQueue,
                navWait: navWait,
                visibleAlerts: visibleAlerts
            )
        }

        public func withNavWaitChange(_ change: (inout [NavWait]) -> Void) -> State {
            var navWait = self.navWait
            change(&navWait)
            return withNavWait(navWait)
        }

        public func withVisibleAlerts(_ visibleAlerts: Set<String>) -> State {
            return State(
                path: path,
                rootRouteContainer: rootRouteContainer,
                nextId: nextId,
                routesState: routesState,
                navOpQueue: navOpQueue,
                navWait: navWait,
                visibleAlerts: visibleAlerts
            )
        }
    }
}

public enum NavWait: Equatable {
    case appear(id: Int)
    case disappear(id: Int)
    case navigationControllerDidShow

    static func forRoot(_ navWait: inout [NavWait]) {
        // navigationControllerDidShow must be called before any navigation is possible
        navWait.append(.navigationControllerDidShow)
    }

    static func forPush(_ navWait: inout [NavWait], oldId: Int, newId: Int) {
        // new route must appear and old route must disappear before we can continue with navigation
        navWait.append(.appear(id: newId))
        navWait.append(.disappear(id: oldId))
    }

    static func forPop(_ navWait: inout [NavWait], oldId: Int) {
        // the active route must disappear and a new controller must
        // appear before we can continue with navigation
        navWait.append(.disappear(id: oldId))

        // in iOS 16 it was enough to wait only for disappear
        // in iOS 17 we also have to wait for navigationControllerDidShow
        navWait.append(.navigationControllerDidShow)
    }
}
