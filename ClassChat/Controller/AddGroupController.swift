//
//  AddGroupController.swift
//  ClassChat
//
//  Created by Stephen Link on 8/16/18.
//  Copyright © 2018 Stephen Link. All rights reserved.
//

import UIKit
import Firebase



class AddGroupController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //MARK: - Instance Variables and Functions
    
    @IBOutlet weak var addGroupTableView: UITableView!
    
    let groupIDs = ["CMSC410", "CMSC411", "ENEE324"]
    var userObj : MyUser!
    var ref : DatabaseReference!
    
    //MARK: - View Controller Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGroupTableView.delegate = self
        addGroupTableView.dataSource = self
        
        ref = Database.database().reference()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Table View Functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupIDs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addGroupCell", for: indexPath)
        cell.textLabel?.text = groupIDs[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //If the group is added successfully dismiss this view, if not do not (as this will actually just dismiss the error message)
        if addGroup(index: indexPath.row) {
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    //MARK: - Add Group Functions
    
    func addGroup(index: Int) -> Bool {
        if userObj != nil {
            
            //check if user is already in the selected group
            if userObj.groups[groupIDs[index]] != nil {
                handleErrors(errMsg: "You are already a member of this group.")
                return false
            } else {
                let groupID = groupIDs[index]
                userObj.groups[groupID] = true
                
                let timestamp = NSDate().timeIntervalSince1970 as NSNumber
                
                //update the database with relevant data
                let userData = [groupID : true]
                let groupData = ["lastMessage" : "\(userObj.username) has joined the group.", "timestamp" : "\(timestamp)"]
                let memberData = ["name" : userObj.username, "uid" : userObj.uid]
                let messageData = ["message" : "\(userObj.username) has joined the group.", "timestamp" : "\(timestamp)", "sender" : "admin", "senderUID" : "\(userObj.uid)", "profileImageURL" : ""]
                
                ref.child("users/\(userObj.uid)/groups").updateChildValues(userData)
                ref.child("groups/\(groupID)").updateChildValues(groupData)
                ref.child("members/\(groupID)").childByAutoId().updateChildValues(memberData)
                ref.child("messages/\(groupID)").childByAutoId().updateChildValues(messageData)
                return true
                
            }
        } else {
            handleErrors(errMsg: "Your user data could not be retrieved. Try closing the app and trying again.")
            return false
        }
    }
    
    //present an error message with a given error message
    func handleErrors(errMsg: String) {
        let alert = UIAlertController(title: "Error", message: errMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .default, handler: { (_) in
        }))
        self.present(alert, animated: true, completion: nil)
        print("alert triggered")
    }
    
    
    

}
