//
//  SignInController.swift
//  ClassChat
//
//  Created by Stephen Link on 8/5/18.
//  Copyright © 2018 Stephen Link. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SignInController: UIViewController {

    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signInButtonPressed(_ sender: RoundedButton) {
        if emailTextField.text != "" && passwordTextField.text != "" {
            Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
                if error != nil {
                    let errorCode = AuthErrorCode(rawValue: error!._code)!
                    self.handleSignInErrors(errorCode)
                } else {
                    print("Login successful")
                    self.navigationController?.popToRootViewController(animated: true)
                }
            })
        }
    }
    
    func handleSignInErrors(_ errorCode: AuthErrorCode) {
       
        var errMsg : String = ""
        switch errorCode {
        case AuthErrorCode.invalidEmail:
            errMsg = "Malformed Email Address"
        case AuthErrorCode.wrongPassword:
            errMsg = "Invalid Email or Password"
        case AuthErrorCode.userNotFound:
            errMsg = "User not found: tap the register button to sign up"
        case AuthErrorCode.networkError:
            errMsg = "Check Network Connection and Try Again"
        default:
            errMsg = "Please try again later"
        }
        
        // Create and present error alert
        let alert = UIAlertController(title: "Error", message: errMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (_) in
            print("Login alert triggered")
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    @IBAction func cancelButtonPressed(_ sender: RoundedButton) {
        dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
