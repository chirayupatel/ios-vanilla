//
//  RegisterViewController.swift
//  Vanilla
//
//  Created by Alex on 7/11/17.
//  Copyright © 2017 Alex. All rights reserved.
//

import UIKit
import FlybitsKernelSDK
import FlybitsContextSDK
import FlybitsPushSDK

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    weak var logInDelegate: UserLogInDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(RegisterViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func submit(sender: Any?) {
        guard let firstName = firstNameTextField.text, firstName.characters.count > 0, let lastName = lastNameTextField.text, lastName.characters.count > 0, let email = emailTextField.text, email.characters.count > 0, let password = passwordTextField.text, password.characters.count > 0 else {
            return
        }
        
        let identityProvider = FlybitsIDP(email: email, password: password, firstName: firstName, lastName: lastName)
        _ = logInDelegate?.connect(with: identityProvider) { success, error in
            guard success == true, error == nil else {
                let alertController = UIAlertController(title: "Failed logging in", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                return
            }
            print("Registered and logged in")
        }
    }
}
