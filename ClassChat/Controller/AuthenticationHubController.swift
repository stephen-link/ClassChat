//
//  AuthenticationHubController.swift
//  ClassChat
//
//  Created by Stephen Link on 8/5/18.
//  Copyright © 2018 Stephen Link. All rights reserved.
//

import UIKit

//This view basically just holds buttons to segue to the Sign In and Register Views
class AuthenticationHubController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Since this view is pushed by a navigationController, I want to hide the navigation bar 
        navigationController?.setNavigationBarHidden(true, animated: true)
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
