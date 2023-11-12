//
//  ErrorManager.swift
//  DigitalHunt
//
//  Created by Dave Stops on 11/11/23.
//

import UIKit

class ErrorManager {
    
    static func showError (view: UIViewController, message: String, gotoRoot: Bool) {  //static (si riferisce al tipo e non alle sue istanze)
        let alertController = UIAlertController (title: "ERRORE", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            if gotoRoot {
                if let navigationController = view.navigationController {
                    navigationController.popToRootViewController(animated: true)
                }
            }
        }
        alertController.addAction(okAction)
        view.present(alertController, animated: true)
    }
}
