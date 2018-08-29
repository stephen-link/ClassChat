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

    //MARK: - Instance Variables and Outlets
    
    var ref : DatabaseReference!
    var emailEntered : Bool = false
    var passwordEntered : Bool = false
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    
    //MARK: - View Controller Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - Auth Functions
    
    @IBAction func registerButtonPressed(_ sender: RoundedButton) {
        // Note: If both email and password fields are empty, error will be weak password, so the case of empty text fields is handled
        //if emailTextField.text != "" && passwordTextField.text != "" {
        if usernameTextField.text! != "" {
            registerUser(username: usernameTextField.text!, email: emailTextField.text!, password: passwordTextField.text!)
        } else {
            handleRegistrationErrors(AuthErrorCode.weakPassword)
        }
       
    }
    
    //Present an error message based on the AuthErrorCode received
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
            if self.usernameTextField.text! == "" || self.emailTextField.text! == "" {
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
    
    //register the user, present error message if error is encountered; send user data to database
    func registerUser(username: String, email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
           
            if error != nil {
                if let errorCode = AuthErrorCode(rawValue: error!._code) {
                    self.handleRegistrationErrors(errorCode)
                    print(error!._code)
                }
            } else {

                //send user data to database
                let userData = ["uid" : user!.uid, "username" : username, "email" : email, "groups" : Dictionary<String,String>()] as [String : Any]
                self.ref.child("users/\(user!.uid)").setValue(userData)
                print("Registration Complete")
                //if registration is successful, pop to root VC, which is the Dashboard Controller
                self.navigationController?.popToRootViewController(animated: true)
            }
        })
    }
    
    // MARK: - Navigation
    
    @IBAction func cancelButtonPressed(_ sender: RoundedButton) {
        dismiss(animated: true, completion: nil)
    }

}
