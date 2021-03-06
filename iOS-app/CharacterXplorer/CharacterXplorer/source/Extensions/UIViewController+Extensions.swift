//
//  UIViewController+Extensions.swift
//  CharacterXplorer
//
//  Created by Boyan Yankov on 2020-W07-15-Feb-Sat.
//  Copyright © 2020 boyankov@yahoo.com. All rights reserved.
//

import UIKit

// MARK: - Embedding
extension UIViewController {
    
    /// Embeds a child view controller.
    /// - Parameters:
    ///   - child: the child view controller that we want to embed.
    ///   - containerView: the container view into which `child` view controller's view will be added as subview.
    ///   - positionChildViewIntoContainerView: configuration function to position `child` view controller's view into passed `containerView`. Caller is also responsible to add `child` view controller's view as subview of passed `containerView`. Defaults to `nil` which will add `child` view controller's view fully constraint to passed `containerView`.
    func embed(_ child: UIViewController,
               containerView: UIView,
               positionChildViewIntoContainerView:((_ childView: UIView, _ containerView: UIView) -> Void)? = nil) throws
    {
        guard child.parent == nil else {
            let error: NSError = NSError(domain: EmbeddingError.domain,
                                         code: EmbeddingError.CodeDescription.parentNotNil.code,
                                         userInfo: [
                                            NSLocalizedDescriptionKey: EmbeddingError.CodeDescription.parentNotNil.description
            ])
            throw error
        }
        self.addChild(child)
        if let _ = positionChildViewIntoContainerView {
            positionChildViewIntoContainerView!(child.view, containerView)
            guard child.view.superview === containerView else {
                child.willMove(toParent: nil)
                child.view.removeFromSuperview()
                let error: NSError = NSError(domain: EmbeddingError.domain,
                                             code: EmbeddingError.CodeDescription.containerViewIsNotUsedAsSuperView.code,
                                             userInfo: [
                                                NSLocalizedDescriptionKey: EmbeddingError.CodeDescription.containerViewIsNotUsedAsSuperView.description
                ])
                throw error
            }
            child.didMove(toParent: self)
        }
        else {
            containerView.addSubview(child.view)
            child.view.translatesAutoresizingMaskIntoConstraints = false
            child.view.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
            child.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
            child.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
            child.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
            child.didMove(toParent: self)
        }
    }
    
    /// Removes a child view controller.
    /// - Parameter child: the child view controller that we want to remove.
    func remove(_ child: UIViewController) throws {
        guard child.parent === self else {
            let error: NSError = NSError(domain: EmbeddingError.domain,
                                         code: EmbeddingError.CodeDescription.childHasDifferentParent.code,
                                         userInfo: [
                                            NSLocalizedDescriptionKey: EmbeddingError.CodeDescription.childHasDifferentParent.description
            ])
            throw error
        }
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
    
    /// Caseless container for all constants and subtypes used to describe embedding errors.
    private enum EmbeddingError {
        static let domain: String = "UIViewController.Embedding"
        
        /// Caseless container of tuples containing error code and description.
        enum CodeDescription {
            static let parentNotNil: (code: Int, description: String)
                = (9001, "Trying to embed a view controller that already has its parent set!")
            static let containerViewIsNotUsedAsSuperView: (code: Int, description: String)
                = (9002, "Passed container_view is not used as child's super_view!")
            static let childHasDifferentParent: (code: Int, description: String)
                = (9003, "Passed child_view_controller is not child of this view controller, that is - it has different parent and can not be removed form this veiw controller!")
        }
    }
}

// MARK: - Error alerts
extension UIViewController {
    /**
     Show alert for error object with custom button and handler. Default alert title is "Error"
     - parameter error: Error object we are displaying alert for
     - parameter actionTitle: custom title for the action button
     - parameter actionHandler: custom handler
     */
    func showAlert(
        for error: NSError,
        alertTitle: String = NSLocalizedString("UIViewController.showAlert.alertTitle.default.Error", comment: AppConstants.LocalizedStringComment.screenTitle),
        actionTitle: String = NSLocalizedString("UIViewController.showAlert.actionTitle.default.OK", comment: AppConstants.LocalizedStringComment.buttonTitle),
        actionHandler: ((_ action: UIAlertAction) -> Void)? = nil)
    {
        let alertTitle: String = "\(alertTitle): \(error.code)"
        let alertMessage: String = error.localizedDescription
        self.showAlertWithTitle(alertTitle, alertMessage: alertMessage, actionTitle: actionTitle, actionHandler: actionHandler)
    }
    
    /**
     Show alert with button and handler.
     - parameter alertTitle: Alert title
     - parameter alertMessage: Alert message we want to display
     - parameter actionTitle: custom title for the action button
     - parameter actionHandler: custom handler
     */
    func showAlertWithTitle(
        _ alertTitle: String? = nil,
        alertMessage: String?,
        actionTitle: String = NSLocalizedString("OK", comment: AppConstants.LocalizedStringComment.buttonTitle),
        actionHandler: ((_ action: UIAlertAction) -> Void)? = nil)
    {
        // present alert to the user
        let alertController: UIAlertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        let alertAction: UIAlertAction = UIAlertAction(title: actionTitle, style: .default, handler: actionHandler)
        alertController.addAction(alertAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}
