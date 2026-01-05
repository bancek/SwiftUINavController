import SwiftUINavController
import XCTest

final class NavControllerTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testPushPop() {
        var (navController, expectedState) = getInitial()

        navController.push(.route1)
        expectedState =
            expectedState
            .withPath([RouteContainer(id: 1, route: .route1)])
            .withNextId(2)
            .withNavWait([.appear(id: 1), .disappear(id: 0)])
            .withRouteStateChange {
                $0[1] = NavController.RouteState(
                    id: 1,
                    route: .route1,
                    inPath: true,
                    visible: false
                )
            }
        XCTAssertEqual(navController.path, navController.state.path)
        XCTAssertEqual(navController.state, expectedState)
        navController.onAppear(RouteContainer(id: 1, route: .route1))
        expectedState =
            expectedState
            .withNavWait([.disappear(id: 0)])
            .withRouteStateChange(1) { $0.withVisible(true) }
        XCTAssertEqual(navController.path, navController.state.path)
        XCTAssertEqual(navController.state, expectedState)
        navController.onDisappear(RouteContainer(id: 0, route: .root))
        expectedState =
            expectedState
            .withNavWait([])
            .withRouteStateChange(0) { $0.withVisible(false) }
        XCTAssertEqual(navController.path, navController.state.path)
        XCTAssertEqual(navController.state, expectedState)

        navController.pop()
        expectedState =
            expectedState
            .withPath([])
            .withNavWait([.disappear(id: 1), .navigationControllerDidShow])
            .withRouteStateChange(1) { $0.withInPath(false) }
        XCTAssertEqual(navController.path, navController.state.path)
        XCTAssertEqual(navController.state, expectedState)
        navController.onAppear(RouteContainer(id: 0, route: .root))
        expectedState =
            expectedState
            .withRouteStateChange(0) { $0.withVisible(true) }
        XCTAssertEqual(navController.path, navController.state.path)
        XCTAssertEqual(navController.state, expectedState)
        navController.onDisappear(RouteContainer(id: 1, route: .route1))
        expectedState =
            expectedState
            .withNavWait([.navigationControllerDidShow])
            .withRouteStateChange { $0.removeValue(forKey: 1) }
        XCTAssertEqual(navController.path, navController.state.path)
        XCTAssertEqual(navController.state, expectedState)
        navController.navigationControllerDidShow()
        expectedState = expectedState.withNavWait([])
        XCTAssertEqual(navController.path, navController.state.path)
        XCTAssertEqual(navController.state, expectedState)
    }

    func testPushPopBeforeDidShow() {
        var (navController, expectedState) = getInitial()

        navController.push(.route1)
        expectedState =
            expectedState
            .withPath([RouteContainer(id: 1, route: .route1)])
            .withNextId(2)
            .withNavWait([.appear(id: 1), .disappear(id: 0)])
            .withRouteStateChange {
                $0[1] = NavController.RouteState(
                    id: 1,
                    route: .route1,
                    inPath: true,
                    visible: false
                )
            }
        XCTAssertEqual(navController.path, navController.state.path)
        XCTAssertEqual(navController.state, expectedState)
        navController.onAppear(RouteContainer(id: 1, route: .route1))
        expectedState =
            expectedState
            .withNavWait([.disappear(id: 0)])
            .withRouteStateChange(1) { $0.withVisible(true) }
        XCTAssertEqual(navController.path, navController.state.path)
        XCTAssertEqual(navController.state, expectedState)

        navController.pop()
        expectedState =
            expectedState
            .withPath([RouteContainer(id: 1, route: .route1)])
            .withNavWait([.disappear(id: 0)])
            .withNavOpQueue([.pop])
        XCTAssertEqual(navController.path, navController.state.path)
        XCTAssertEqual(navController.state, expectedState)
        navController.onDisappear(RouteContainer(id: 0, route: .root))
        expectedState =
            expectedState
            .withPath([])
            .withRouteStateChange(0) { $0.withVisible(false) }
            .withRouteStateChange(1) { $0.withInPath(false) }
            .withNavWait([.disappear(id: 1), .navigationControllerDidShow])
            .withNavOpQueue([])
        XCTAssertEqual(navController.path, navController.state.path)
        XCTAssertEqual(navController.state, expectedState)
        navController.onAppear(RouteContainer(id: 0, route: .root))
        expectedState =
            expectedState
            .withRouteStateChange(0) { $0.withVisible(true) }
        XCTAssertEqual(navController.path, navController.state.path)
        XCTAssertEqual(navController.state, expectedState)
        navController.onDisappear(RouteContainer(id: 1, route: .route1))
        expectedState =
            expectedState
            .withNavWait([.navigationControllerDidShow])
            .withRouteStateChange { $0.removeValue(forKey: 1) }
        XCTAssertEqual(navController.path, navController.state.path)
        XCTAssertEqual(navController.state, expectedState)
        navController.navigationControllerDidShow()
        expectedState = expectedState.withNavWait([])
        XCTAssertEqual(navController.path, navController.state.path)
        XCTAssertEqual(navController.state, expectedState)
    }

    func testPushPopPath() {
        var (navController, expectedState) = getInitial()

        navController.push(.route1)
        expectedState =
            expectedState
            .withPath([RouteContainer(id: 1, route: .route1)])
            .withNextId(2)
            .withNavWait([.appear(id: 1), .disappear(id: 0)])
            .withRouteStateChange {
                $0[1] = NavController.RouteState(
                    id: 1,
                    route: .route1,
                    inPath: true,
                    visible: false
                )
            }
        XCTAssertEqual(navController.path, navController.state.path)
        XCTAssertEqual(navController.state, expectedState)
        navController.onAppear(RouteContainer(id: 1, route: .route1))
        expectedState =
            expectedState
            .withNavWait([.disappear(id: 0)])
            .withRouteStateChange(1) { $0.withVisible(true) }
        XCTAssertEqual(navController.path, navController.state.path)
        XCTAssertEqual(navController.state, expectedState)
        navController.onDisappear(RouteContainer(id: 0, route: .root))
        expectedState =
            expectedState
            .withNavWait([])
            .withRouteStateChange(0) { $0.withVisible(false) }
        XCTAssertEqual(navController.path, navController.state.path)
        XCTAssertEqual(navController.state, expectedState)

        navController.path.removeLast()
        expectedState =
            expectedState
            .withPath([])
            .withNavWait([.disappear(id: 1), .navigationControllerDidShow])
            .withRouteStateChange(1) { $0.withInPath(false) }
        XCTAssertEqual(navController.path, navController.state.path)
        XCTAssertEqual(navController.state, expectedState)
        navController.onAppear(RouteContainer(id: 0, route: .root))
        expectedState =
            expectedState
            .withRouteStateChange(0) { $0.withVisible(true) }
        XCTAssertEqual(navController.path, navController.state.path)
        XCTAssertEqual(navController.state, expectedState)
        navController.onDisappear(RouteContainer(id: 1, route: .route1))
        expectedState =
            expectedState
            .withNavWait([.navigationControllerDidShow])
            .withRouteStateChange { $0.removeValue(forKey: 1) }
        XCTAssertEqual(navController.path, navController.state.path)
        XCTAssertEqual(navController.state, expectedState)
        navController.navigationControllerDidShow()
        expectedState = expectedState.withNavWait([])
        XCTAssertEqual(navController.path, navController.state.path)
        XCTAssertEqual(navController.state, expectedState)
    }

    func testReplacePathEmpty() {
        let (navController, _) = getInitial()

        navController.replace([.route1, .route2])
        XCTAssertEqual(navController.state.path, [RouteContainer(id: 1, route: .route1)])
        XCTAssertEqual(navController.state.navOpQueue, [.replace(routes: [.route1, .route2])])
        navController.onAppear(RouteContainer(id: 1, route: .route1))
        navController.onDisappear(RouteContainer(id: 0, route: .root))
        XCTAssertEqual(
            navController.state.path,
            [RouteContainer(id: 1, route: .route1), RouteContainer(id: 2, route: .route2)])
        navController.onAppear(RouteContainer(id: 2, route: .route2))
        navController.onDisappear(RouteContainer(id: 1, route: .route1))
        XCTAssertTrue(navController.state.navOpQueue.isEmpty)
        XCTAssertTrue(navController.state.navWait.isEmpty)
    }

    func testReplaceRoutesEmpty() {
        let (navController, _) = getInitial()

        navController.onAppear(RouteContainer(id: 0, route: .root))
        navController.navigationControllerDidShow()
        navController.push(.route1)
        navController.onAppear(RouteContainer(id: 1, route: .route1))
        navController.onDisappear(RouteContainer(id: 0, route: .root))
        navController.push(.route2)
        navController.onAppear(RouteContainer(id: 2, route: .route2))
        navController.onDisappear(RouteContainer(id: 1, route: .route1))
        XCTAssertEqual(
            navController.state.path,
            [RouteContainer(id: 1, route: .route1), RouteContainer(id: 2, route: .route2)])
        XCTAssertTrue(navController.state.navOpQueue.isEmpty)
        XCTAssertTrue(navController.state.navWait.isEmpty)

        navController.replace([])
        XCTAssertEqual(navController.state.path, [RouteContainer(id: 1, route: .route1)])
        XCTAssertEqual(navController.state.navOpQueue, [.replace(routes: [])])
        XCTAssertEqual(
            navController.state.navWait, [.disappear(id: 2), .navigationControllerDidShow])
        navController.onAppear(RouteContainer(id: 1, route: .route1))
        XCTAssertEqual(navController.state.path, [RouteContainer(id: 1, route: .route1)])
        XCTAssertEqual(navController.state.navOpQueue, [.replace(routes: [])])
        XCTAssertEqual(
            navController.state.navWait, [.disappear(id: 2), .navigationControllerDidShow])
        navController.onDisappear(RouteContainer(id: 2, route: .route2))
        XCTAssertEqual(navController.state.path, [RouteContainer(id: 1, route: .route1)])
        XCTAssertEqual(navController.state.navOpQueue, [.replace(routes: [])])
        XCTAssertEqual(navController.state.navWait, [.navigationControllerDidShow])
        navController.navigationControllerDidShow()
        XCTAssertEqual(navController.state.path, [])
        XCTAssertEqual(navController.state.navOpQueue, [.replace(routes: [])])
        XCTAssertEqual(
            navController.state.navWait, [.disappear(id: 1), .navigationControllerDidShow])
        navController.onAppear(RouteContainer(id: 0, route: .root))
        XCTAssertEqual(navController.state.path, [])
        XCTAssertEqual(navController.state.navOpQueue, [.replace(routes: [])])
        XCTAssertEqual(
            navController.state.navWait, [.disappear(id: 1), .navigationControllerDidShow])
        navController.onDisappear(RouteContainer(id: 1, route: .route1))
        XCTAssertEqual(navController.state.path, [])
        XCTAssertEqual(navController.state.navOpQueue, [.replace(routes: [])])
        XCTAssertEqual(navController.state.navWait, [.navigationControllerDidShow])
        navController.navigationControllerDidShow()
        XCTAssertEqual(navController.state.path, [])
        XCTAssertTrue(navController.state.navOpQueue.isEmpty)
        XCTAssertTrue(navController.state.navWait.isEmpty)
    }

    func testReplaceRoutesNoChange() {
        let (navController, _) = getInitial()

        navController.onAppear(RouteContainer(id: 0, route: .root))
        navController.navigationControllerDidShow()
        navController.push(.route1)
        navController.onAppear(RouteContainer(id: 1, route: .route1))
        navController.onDisappear(RouteContainer(id: 0, route: .root))
        navController.push(.route2)
        navController.onAppear(RouteContainer(id: 2, route: .route2))
        navController.onDisappear(RouteContainer(id: 1, route: .route1))
        XCTAssertEqual(
            navController.state.path,
            [RouteContainer(id: 1, route: .route1), RouteContainer(id: 2, route: .route2)])
        XCTAssertTrue(navController.state.navOpQueue.isEmpty)
        XCTAssertTrue(navController.state.navWait.isEmpty)

        navController.replace([.route1, .route2])
        XCTAssertEqual(
            navController.state.path,
            [RouteContainer(id: 1, route: .route1), RouteContainer(id: 2, route: .route2)])
        XCTAssertTrue(navController.state.navOpQueue.isEmpty)
        XCTAssertTrue(navController.state.navWait.isEmpty)
    }

    func testReplaceRoutesChangeLast() {
        let (navController, _) = getInitial()

        navController.onAppear(RouteContainer(id: 0, route: .root))
        navController.navigationControllerDidShow()
        navController.push(.route1)
        navController.onAppear(RouteContainer(id: 1, route: .route1))
        navController.onDisappear(RouteContainer(id: 0, route: .root))
        navController.push(.route2)
        navController.onAppear(RouteContainer(id: 2, route: .route2))
        navController.onDisappear(RouteContainer(id: 1, route: .route1))
        XCTAssertEqual(
            navController.state.path,
            [RouteContainer(id: 1, route: .route1), RouteContainer(id: 2, route: .route2)])
        XCTAssertTrue(navController.state.navOpQueue.isEmpty)
        XCTAssertTrue(navController.state.navWait.isEmpty)

        navController.replace([.route1, .route3])
        XCTAssertEqual(navController.state.path, [RouteContainer(id: 1, route: .route1)])
        XCTAssertEqual(navController.state.navOpQueue, [.replace(routes: [.route1, .route3])])
        XCTAssertEqual(
            navController.state.navWait, [.disappear(id: 2), .navigationControllerDidShow])
        navController.onAppear(RouteContainer(id: 1, route: .route1))
        XCTAssertEqual(navController.state.path, [RouteContainer(id: 1, route: .route1)])
        XCTAssertEqual(navController.state.navOpQueue, [.replace(routes: [.route1, .route3])])
        XCTAssertEqual(
            navController.state.navWait, [.disappear(id: 2), .navigationControllerDidShow])
        navController.onDisappear(RouteContainer(id: 2, route: .route2))
        XCTAssertEqual(navController.state.path, [RouteContainer(id: 1, route: .route1)])
        XCTAssertEqual(navController.state.navOpQueue, [.replace(routes: [.route1, .route3])])
        XCTAssertEqual(navController.state.navWait, [.navigationControllerDidShow])
        navController.navigationControllerDidShow()
        XCTAssertEqual(
            navController.state.path,
            [RouteContainer(id: 1, route: .route1), RouteContainer(id: 3, route: .route3)])
        XCTAssertEqual(navController.state.navOpQueue, [.replace(routes: [.route1, .route3])])
        XCTAssertEqual(navController.state.navWait, [.appear(id: 3), .disappear(id: 1)])
        navController.onAppear(RouteContainer(id: 3, route: .route3))
        XCTAssertEqual(
            navController.state.path,
            [RouteContainer(id: 1, route: .route1), RouteContainer(id: 3, route: .route3)])
        XCTAssertEqual(navController.state.navOpQueue, [.replace(routes: [.route1, .route3])])
        XCTAssertEqual(navController.state.navWait, [.disappear(id: 1)])
        navController.onDisappear(RouteContainer(id: 1, route: .route1))
        XCTAssertEqual(
            navController.state.path,
            [RouteContainer(id: 1, route: .route1), RouteContainer(id: 3, route: .route3)])
        XCTAssertTrue(navController.state.navOpQueue.isEmpty)
        XCTAssertTrue(navController.state.navWait.isEmpty)
    }

    func testPushMultiWaitForDidShow() {
        let navController = NavController<TestRoute>(rootRoute: .root)
        var expectedState = NavController<TestRoute>.State(rootRoute: .root)
        XCTAssertEqual(navController.path, navController.state.path)
        XCTAssertEqual(navController.state, expectedState)

        navController.push(.route1)
        expectedState = expectedState.withNavOpQueue([.push(route: .route1)])
        XCTAssertEqual(navController.path, navController.state.path)
        XCTAssertEqual(navController.state, expectedState)

        navController.push(.route2)
        expectedState = expectedState.withNavOpQueue([.push(route: .route1), .push(route: .route2)])
        XCTAssertEqual(navController.path, navController.state.path)
        XCTAssertEqual(navController.state, expectedState)

        navController.onAppear(RouteContainer(id: 0, route: .root))
        expectedState = expectedState.withRouteStateVisible(id: 0, visible: true)
        XCTAssertEqual(navController.path, navController.state.path)
        XCTAssertEqual(navController.state, expectedState)
        navController.navigationControllerDidShow()
        expectedState =
            expectedState
            .withPath([RouteContainer(id: 1, route: .route1)])
            .withNextId(2)
            .withNavWait([.appear(id: 1), .disappear(id: 0)])
            .withRouteStateChange {
                $0[1] = NavController.RouteState(
                    id: 1,
                    route: .route1,
                    inPath: true,
                    visible: false
                )
            }
            .withNavOpQueue([.push(route: .route2)])
        XCTAssertEqual(navController.path, navController.state.path)
        XCTAssertEqual(navController.state, expectedState)

        navController.onAppear(RouteContainer(id: 1, route: .route1))
        expectedState =
            expectedState
            .withNavWait([.disappear(id: 0)])
            .withRouteStateChange(1) { $0.withVisible(true) }
        XCTAssertEqual(navController.path, navController.state.path)
        XCTAssertEqual(navController.state, expectedState)
        navController.onDisappear(RouteContainer(id: 0, route: .root))
        expectedState =
            expectedState
            .withPath([
                RouteContainer(id: 1, route: .route1), RouteContainer(id: 2, route: .route2),
            ])
            .withNextId(3)
            .withNavWait([.appear(id: 2), .disappear(id: 1)])
            .withRouteStateChange(0) { $0.withVisible(false) }
            .withRouteStateChange {
                $0[2] = NavController.RouteState(
                    id: 2,
                    route: .route2,
                    inPath: true,
                    visible: false
                )
            }
            .withNavOpQueue([])
        XCTAssertEqual(navController.path, navController.state.path)
        XCTAssertEqual(navController.state, expectedState)

        navController.onAppear(RouteContainer(id: 2, route: .route2))
        expectedState =
            expectedState
            .withNavWait([.disappear(id: 1)])
            .withRouteStateChange(2) { $0.withVisible(true) }
        XCTAssertEqual(navController.path, navController.state.path)
        XCTAssertEqual(navController.state, expectedState)
        navController.onDisappear(RouteContainer(id: 1, route: .root))
        expectedState =
            expectedState
            .withNavWait([])
            .withRouteStateChange(1) { $0.withVisible(false) }
        XCTAssertEqual(navController.path, navController.state.path)
        XCTAssertEqual(navController.state, expectedState)
    }

    func testAlertWait() {
        var (navController, expectedState) = getInitial()

        navController.alertDisplayed("alert1")
        expectedState = expectedState.withVisibleAlerts(["alert1"])
        XCTAssertEqual(navController.path, navController.state.path)
        XCTAssertEqual(navController.state, expectedState)

        navController.push(.route1)
        expectedState = expectedState.withNavOpQueue([.push(route: .route1)])
        XCTAssertEqual(navController.path, navController.state.path)
        XCTAssertEqual(navController.state, expectedState)

        navController.alertHidden("alert1")
        expectedState =
            expectedState
            .withVisibleAlerts([])
            .withNavOpQueue([])
            .withPath([RouteContainer(id: 1, route: .route1)])
            .withNextId(2)
            .withNavWait([.appear(id: 1), .disappear(id: 0)])
            .withRouteStateChange {
                $0[1] = NavController.RouteState(
                    id: 1,
                    route: .route1,
                    inPath: true,
                    visible: false
                )
            }
        XCTAssertEqual(navController.path, navController.state.path)
        XCTAssertEqual(navController.state, expectedState)
    }

    func testEnsureViewModel() {
        let (navController, _) = getInitial()

        navController.push(.route1)

        let vm1 = navController.ensureViewModel(
            routeContainer: RouteContainer(id: 1, route: .route1),
            create: {
                TestViewModel()
            })
        let vm1Cached =
            navController.viewModels[1]![String(describing: TestViewModel.self)] as! TestViewModel
        XCTAssertEqual(vm1Cached, vm1)

        navController.onAppear(RouteContainer(id: 1, route: .route1))
        navController.onDisappear(RouteContainer(id: 0, route: .root))

        let vm2 = navController.ensureViewModel(
            routeContainer: RouteContainer(id: 1, route: .route1),
            create: {
                TestViewModel()
            })
        XCTAssertEqual(vm2, vm1)

        navController.pop()

        let vm3 = navController.ensureViewModel(
            routeContainer: RouteContainer(id: 1, route: .route1),
            create: {
                TestViewModel()
            })
        XCTAssertEqual(vm3, vm1)

        navController.onAppear(RouteContainer(id: 0, route: .root))

        let vm4 = navController.ensureViewModel(
            routeContainer: RouteContainer(id: 1, route: .route1),
            create: {
                TestViewModel()
            })
        XCTAssertEqual(vm4, vm1)

        navController.onDisappear(RouteContainer(id: 1, route: .route1))

        XCTAssertNil(navController.viewModels[1])

        let vm5 = navController.ensureViewModel(
            routeContainer: RouteContainer(id: 1, route: .route1),
            create: {
                TestViewModel()
            })
        XCTAssertNotEqual(vm5, vm1)

        XCTAssertNil(navController.viewModels[1])

        let vm6 = navController.ensureViewModel(
            routeContainer: RouteContainer(id: 1, route: .route1),
            create: {
                TestViewModel()
            })
        XCTAssertNotEqual(vm6, vm5)
    }

    // MARK: Test data

    enum TestRoute: Hashable {
        case root
        case route1
        case route2
        case route3
        case route4
        case route5
    }

    struct TestViewModel: Equatable {
        var id: String

        init() {
            self.id = UUID().uuidString
        }
    }

    func getInitial() -> (NavController<TestRoute>, NavController<TestRoute>.State) {
        let navController = NavController<TestRoute>(rootRoute: .root)
        var expectedState = NavController<TestRoute>.State(rootRoute: .root)
        XCTAssertEqual(navController.path, navController.state.path)
        XCTAssertEqual(navController.state, expectedState)
        navController.onAppear(RouteContainer(id: 0, route: .root))
        expectedState = expectedState.withRouteStateVisible(id: 0, visible: true)
        XCTAssertEqual(navController.path, navController.state.path)
        XCTAssertEqual(navController.state, expectedState)
        navController.navigationControllerDidShow()
        expectedState = expectedState.withNavWait([])
        XCTAssertEqual(navController.path, navController.state.path)
        XCTAssertEqual(navController.state, expectedState)

        return (navController, expectedState)
    }
}
