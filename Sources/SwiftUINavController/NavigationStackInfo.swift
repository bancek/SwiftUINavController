import NavigationControllerDelegateProxy
import SwiftUI
import UIKit

// inspired by https://github.com/siteline/SwiftUI-Introspect

struct NavigationStackInfo: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController

    let willShow: (() -> Void)?
    let didShow: (() -> Void)?

    @State private var navigationControllerDelegateProxy: UINavigationControllerDelegateProxy?

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()

        viewController.view = PatchUIView { [weak viewController] in
            guard let viewController = viewController else { return }

            if let parent = viewController.parent {
                let children = parent.children

                for child in children {
                    if let navigationController = child as? UINavigationController {
                        if navigationController.delegate != nil {
                            if let _ = navigationController.delegate!
                                as? UINavigationControllerDelegateProxy
                            {
                                // already patched
                            } else {
                                let forward = UINavigationControllerDelegateProxyForward {
                                    willShow?()
                                } didShow: {
                                    didShow?()
                                }

                                navigationControllerDelegateProxy =
                                    UINavigationControllerDelegateProxy(
                                        delegate: navigationController.delegate!, forwardTo: forward
                                    )

                                navigationController.delegate =
                                    (navigationControllerDelegateProxy
                                        as! UINavigationControllerDelegate)
                            }
                        }
                    }
                }
            }
        }

        return viewController
    }

    func updateUIViewController(_ viewController: UIViewController, context: Context) {}
}

extension View {
    func navigationStackInfo(willShow: (() -> Void)? = nil, didShow: (() -> Void)? = nil)
        -> some View
    {
        overlay {
            NavigationStackInfo(willShow: willShow, didShow: didShow).frame(width: 0, height: 0)
        }
    }
}

private class PatchUIView: UIView {
    private var moveToWindowHandler: (() -> Void)?

    public init(moveToWindowHandler: @escaping () -> Void) {
        super.init(frame: .zero)

        self.isHidden = true
        self.isUserInteractionEnabled = false

        self.moveToWindowHandler = moveToWindowHandler
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func didMoveToWindow() {
        super.didMoveToWindow()

        moveToWindowHandler?()
    }
}
