import UIKit
import SwiftUI

class StatusBarConfigurator: ObservableObject {

    static var shared = StatusBarConfigurator()
    
    private var window: UIWindow?
    
    var statusBarStyleDark: UIStatusBarStyle = .darkContent {
        didSet {
            window?.rootViewController?.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    var statusBarStyleLight: UIStatusBarStyle = .lightContent {
        didSet {
            window?.rootViewController?.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    fileprivate func prepare(scene: UIWindowScene, darkContent: Bool) {
        if window == nil {
            let window = UIWindow(windowScene: scene)
            let viewController = ViewController()
            viewController.darkContent = darkContent
            viewController.configurator = self
            window.rootViewController = viewController
            window.frame = UIScreen.main.bounds
            window.alpha = 0
            self.window = window
        }
        window?.windowLevel = .statusBar
        window?.makeKeyAndVisible()
    }
    
    fileprivate class ViewController: UIViewController {
        weak var configurator: StatusBarConfigurator!
        var darkContentDef: Bool {
            UITraitCollection.current.userInterfaceStyle.isDarkMode
        }
        var darkContent: Bool? = nil
        
        override var preferredStatusBarStyle: UIStatusBarStyle {
            (darkContent ?? darkContentDef) ? configurator.statusBarStyleDark : configurator.statusBarStyleLight
        }
    }
}

fileprivate struct SceneFinder: UIViewRepresentable {
    
    var getScene: ((UIWindowScene) -> ())?
    
    func makeUIView(context: Context) -> View { View() }
    func updateUIView(_ uiView: View, context: Context) { uiView.getScene = getScene }
    
    class View: UIView {
        var getScene: ((UIWindowScene) -> ())?
        override func didMoveToWindow() {
            if let scene = window?.windowScene {
                getScene?(scene)
            }
        }
    }
}

extension View {
    func prepareStatusBarConfigurator(_ darkContent: Bool) -> some View {
        return self.background(SceneFinder { scene in
            StatusBarConfigurator.shared.prepare(scene: scene, darkContent: darkContent)
        })
    }
}
