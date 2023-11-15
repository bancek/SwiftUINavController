import UIKit

class UINavigationControllerDelegateProxyForward: NSObject, UINavigationControllerDelegate {
    private let willShow: () -> Void
    private let didShow: () -> Void

    init(willShow: @escaping () -> Void, didShow: @escaping () -> Void) {
        self.willShow = willShow
        self.didShow = didShow
    }

    func navigationController(
        _ navigationController: UINavigationController, willShow viewController: UIViewController,
        animated: Bool
    ) {
        self.willShow()
    }

    func navigationController(
        _ navigationController: UINavigationController, didShow viewController: UIViewController,
        animated: Bool
    ) {
        self.didShow()
    }
}
