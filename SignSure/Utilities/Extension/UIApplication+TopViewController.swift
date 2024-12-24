//
//  UIApplication+TopViewController.swift
//  SignSure
//
//  Created by Petrit Vosha on 23.12.2024.
//

import UIKit

extension UIApplication {
    // Retrieves the topmost view controller from the key window.
    class func topViewController(base: UIViewController? = UIApplication.shared.connectedScenes
                                    .filter { $0.activationState == .foregroundActive }
                                    .compactMap { $0 as? UIWindowScene }
                                    .first?.windows
                                    .filter { $0.isKeyWindow }.first?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(base: selected)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
