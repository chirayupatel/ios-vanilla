//
//  LogInViewController.swift
//  Vanilla
//
//  Created by Alex on 7/11/17.
//  Copyright © 2017 Alex. All rights reserved.
//

import UIKit
import FlybitsKernelSDK
import FlybitsContextSDK
import FlybitsPushSDK

protocol UserLogInDelegate: class {
    func connect(with flybitsIDP: FlybitsIDP, completion: @escaping (Bool, Error?) -> ())
    func logout(sender: Any?)
}

class LogInViewController: UIViewController, UITextFieldDelegate, UserLogInDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(LogInViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        // Temporary fix for backend issue
        let projectID = (UIApplication.shared.delegate as! AppDelegate).projectID!
        let scopes = (UIApplication.shared.delegate as! AppDelegate).scopes
        let email = UserDefaults.standard.value(forKey: "email") as? String
        let password = UserDefaults.standard.value(forKey: "password") as? String
        if email == nil || password == nil {
            return
        }
        let identityProvider = FlybitsIDP(email: email!, password: password!)
        let flybitsManager = FlybitsManager(projectID: projectID, idProvider: identityProvider, scopes: scopes)
        
        _ = flybitsManager.connect { user, error in
            guard let user = user, error == nil else {
                print(error!.localizedDescription)
                return
            }
            print("Welcome back, \(user.firstname!)")
            print("User is connected. Will show relevant content.")
            let relevantContentVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RelevantContent")
            relevantContentVC.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(LogInViewController.logout(sender:)))
            DispatchQueue.main.async {
                self.show(relevantContentVC, sender: self)
            }
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func submit(sender: Any?) {
        guard let email = emailTextField.text, email.characters.count > 0,
            let password = passwordTextField.text, password.characters.count > 0 else {
            return
        }
        
        let identityProvider = FlybitsIDP(email: email, password: password)
        connect(with: identityProvider) { success, error in
            guard success == true, error == nil else {
                let alertController = UIAlertController(title: "Failed logging in", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                return
            }
            print("Logged in")
            
            UserDefaults.standard.set(email, forKey: "email")
            UserDefaults.standard.set(password, forKey: "password")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "RegisterSegue" {
            (segue.destination as! RegisterViewController).logInDelegate = self
        }
    }
    
    // MARK: - UserLogInDelegate
    
    func connect(with flybitsIDP: FlybitsIDP, completion: @escaping (Bool, Error?) -> ()) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let projectID = appDelegate.projectID!
        let scopes = appDelegate.scopes
    
        let flybitsManager = FlybitsManager(projectID: projectID, idProvider: flybitsIDP, scopes: scopes)
        (UIApplication.shared.delegate as! AppDelegate).flybitsManager = flybitsManager
        
        // Returns a cancellable request like all of our other requests. We disregard as we probably don't care to cancel here.
        _ = flybitsManager.connect { user, error in
            guard let user = user, error == nil else {
                print("Failed to connect")
                completion(false, NSError(domain: "ios-vanilla", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to connect"]))
                return
            }
            print("Welcome, \(user.firstname!)")
            self.showRelevantContent()
            completion(true, nil)
        }
    }
    
    func showRelevantContent() {
        let relevantContent = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RelevantContent")
        relevantContent.navigationItem.hidesBackButton = true
        relevantContent.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.plain, target: self, action: #selector(LogInViewController.logout(sender:)))
        DispatchQueue.main.async {
            self.show(relevantContent, sender: self)
        }
    }
    
    func logout(sender: Any?) {
        _ = navigationController?.popViewController(animated: true)
        var flybitsManager = (UIApplication.shared.delegate as! AppDelegate).flybitsManager
        if flybitsManager == nil {
            
            // When we launch the app and the static method FlybitsManager.isConnected(completion:)
            // is called and the user wishes to logout, we are forced to re-instantiate flybitsManager
            // from scratch. As a result, and until we make this easier very soon, it is required
            // that the user's credentials be stored in the Keychain so that this data is safe.
            //
            // In the meantime, as this is merely a demo/proof of concept, we store the user's
            // credentials in UserDefaults.
            
            let projectID = (UIApplication.shared.delegate as! AppDelegate).projectID!
            let scopes: [FlybitsScope] = [KernelScope(), ContextScope(timeToUploadContext: 1, timeUnit: Utilities.TimeUnit.minutes), PushScope()]
            let identityProvider = FlybitsIDP(email: UserDefaults.standard.string(forKey: "email")!, password: UserDefaults.standard.string(forKey: "password")!)
            flybitsManager = FlybitsManager(projectID: projectID, idProvider: identityProvider, scopes: scopes)
        }
        _ = flybitsManager?.disconnect { jwt, error in
            guard let jwt = jwt, error == nil else {
                print(error!.localizedDescription)
                return
            }
            print("Logged out with jwt: \(jwt)")
        }
    }
}
