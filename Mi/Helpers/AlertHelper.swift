//
//  AlertHelper.swift
//  Mi
//
//  Created by Vonley on 10/10/22.
//

import Foundation
import UIKit
class AlertHelper {
    static func alert(title: String, message: String, onResult: @escaping (UIAlertAction) -> Void) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "OK",  style: .default) { action in
            onResult(action)
        }
        
        alertVC.addAction(saveAction)
        let viewController = UIApplication.shared.windows.first!.rootViewController!
        viewController.present(alertVC, animated: true, completion: nil)
    }
    
    
    static func alertDecision(title: String, message: String, onResult: @escaping (UIAlertAction) -> Void) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Yes",  style: .default) { action in
            onResult(action)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",  style: .cancel) { action in
            onResult(action)
        }
        
        alertVC.addAction(saveAction)
        alertVC.addAction(cancelAction)
        let viewController = UIApplication.shared.windows.first!.rootViewController!
        viewController.present(alertVC, animated: true, completion: nil)
    }
}
func alertMessage(
    title: String,
    message: String,
    placeholder: String,
    onConfirm: @escaping (String) -> Void,
    onCancel: @escaping () -> Void,
    text: String? = nil
) {
    let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    let saveAction = UIAlertAction(title: "Add",  style: .default) { action in
                                    
    guard let textField = alertVC.textFields?.first,
        let nameToSave = textField.text else {
            return
        }
        onConfirm(nameToSave)
    }
    
    let cancelAction = UIAlertAction(title: "Cancel",
                                     style: .cancel) { action in
        onCancel()
    }
    alertVC.addTextField { tf in
        tf.placeholder = placeholder
        if let t = text {
            tf.text = t
        }
    }
    alertVC.addAction(saveAction)
    alertVC.addAction(cancelAction)
    let viewController = UIApplication.shared.windows.first!.rootViewController!
    viewController.present(alertVC, animated: true, completion: nil)
}
