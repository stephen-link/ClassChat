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

    //MARK: - View Controller Functions
    
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

}
