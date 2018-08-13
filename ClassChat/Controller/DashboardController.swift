//
//  DashboardController.swift
//  ClassChat
//
//  Created by Stephen Link on 8/11/18.
//  Copyright © 2018 Stephen Link. All rights reserved.
//

import UIKit
import Firebase

class DashboardController: UIViewController {

    var ref : DatabaseReference!
    var userObj : MyUser?
    var user : User? {
        didSet {
            authenticateUser()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        print("Dashboard Controller viewDidLoad")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func authenticateUser() {
        
        ref.child("users\(user!.uid)").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                let userData = snapshot.value as! Dictionary<String,String>
                self.userObj = MyUser(email: userData["email"] ?? "", password: userData["password"] ?? "", uid: userData["uid"] ?? "")
                print("user authenticated")
                self.retrieveGroups()
            } else {
                print("user not found")
            }
        }
        
    }
    
    func retrieveGroups() {
        
    }
    
    @IBAction func menuButtonPressed(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            print("Logout Successful!")
            print(navigationController.debugDescription as Any)
            
            //performSegue(withIdentifier: "unwind", sender: self)
        } catch {
            print("Logout: there's a problem")
        }
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
