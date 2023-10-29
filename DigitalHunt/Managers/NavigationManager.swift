//
//  NavigationManager.swift
//  DigitalHunt
//
//  Created by Dave Stops on 28/10/23.
//

import UIKit

class NavigationManager {
    static let shared = NavigationManager()

    private init() {}

    func setupBackButton(for viewController: UIViewController, target: Any?, action: Selector) {
        let newBackButton = UIBarButtonItem(title: "Annulla", style: .plain, target: target, action: action)
        viewController.navigationItem.leftBarButtonItem = newBackButton
    }

    func showCancelConfirmationAlert(on viewController: UIViewController, confirmAction: @escaping () -> Void) {
        let ac = UIAlertController(title: "Annullare la gara in corso? Questa azione cancellerà tutti i tuoi progressi", message: nil, preferredStyle: .alert)
        let yes = UIAlertAction(title: "Si", style: .destructive) { _ in
            // Esegui le azioni di annullamento
            confirmAction()
        }
        let no = UIAlertAction(title: "No", style: .default, handler: nil)
        ac.addAction(yes)
        ac.addAction(no)
        viewController.present(ac, animated: true, completion: nil)
    }
}


