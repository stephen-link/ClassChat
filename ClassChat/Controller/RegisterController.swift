//
//  RegisterController.swift
//  ClassChat
//
//  Created by Stephen Link on 8/5/18.
//  Copyright © 2018 Stephen Link. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth


class RegisterController: UIViewController {

    var ref : DatabaseReference!
    var emailEntered : Bool = false
    var passwordEntered : Bool = false
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        emailTextField.tag = 1
        passwordTextField.tag = 2
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    @IBAction func registerButtonPressed(_ sender: RoundedButton) {
        // Note: If both fields are empty, error will be weak password
        //if emailTextField.text != "" && passwordTextField.text != "" {
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
                if error != nil {
                    if let errorCode = AuthErrorCode(rawValue: error!._code) {
                        self.handleRegistrationErrors(errorCode)
                        print(error!._code)
                    }
                } else {
                    //let myUser = MyUser(email: self.emailTextField.text!, password: self.passwordTextField.text!, uid: user!.uid)
                    //Note: In a production app, the user's password would not be stored in plain text
                    let userData = ["email" : self.emailTextField.text!, "password" : self.passwordTextField.text!, "uid" : user!.uid]
                    self.ref.child("users/\(user!.uid)").setValue(userData)
                    print("Registration Complete")
                    self.navigationController?.popToRootViewController(animated: true)
                }
            })
       
    }
    
    @IBAction func cancelButtonPressed(_ sender: RoundedButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func handleRegistrationErrors(_ errorCode: AuthErrorCode) {
        print("Registration Error Triggered")
        
        var errMsg : String = ""
        switch errorCode {
        case AuthErrorCode.invalidEmail:
            errMsg = "Malformed Email Address"
        case AuthErrorCode.emailAlreadyInUse:
            errMsg = "This Email Address has already been registered"
        case AuthErrorCode.weakPassword:
            //If both fields are empty, error thrown will be weak password, check for that case here
            if self.emailTextField.text! == "" {
                errMsg = "Please Enter All Fields"
            } else {
                errMsg = "Passwords must be 6 or more characters long"
            }
        case AuthErrorCode.networkError:
            errMsg = "Check Network Connection and Try Again"
        case AuthErrorCode.missingEmail:
            errMsg = "Please Enter All Fields"
        default:
            errMsg = "Please try again later"
        }
        
        // Create and present error alert
        let alert = UIAlertController(title: "Error", message: errMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (_) in
            print("Register alert triggered")
        }))
        self.present(alert, animated: true, completion: nil)
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
