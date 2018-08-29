//
//  DashboardController.swift
//  ClassChat
//
//  Created by Stephen Link on 8/11/18.
//  Copyright © 2018 Stephen Link. All rights reserved.
//

import UIKit
import Firebase

class DashboardController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - Instance Variables and Outlets

    var ref : DatabaseReference!
    var userObj : MyUser?
    let formatter = DateFormatter()
    var initializationComplete : Bool = false
    var groups : [GroupInfo] = [GroupInfo]()
    
    //store the id and observer handle of groups so that observers can be removed when view disappears
    var groupHandles : Dictionary<String,UInt> = Dictionary<String,UInt>()
    var numberGroups : Int = 0
    var user : User? {
        didSet {
            print("didSet user")
            //authenticate the user with the Firebase user object once it is set
            authenticateUser()
        }
    }
    
    @IBOutlet weak var groupTableView: UITableView!
    
    //MARK: - View Controller Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        //setup tableView
        groupTableView.delegate = self
        groupTableView.dataSource = self
        
        // setup date formatter
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "MMM dd, YYYY;h:mm aa"
        print("Dashboard Controller viewDidLoad")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if userObj != nil {
            print("fdafa \(userObj!.groups.keys.count)")
            for key in userObj!.groups.keys {
                print("key: \(key), value: \(userObj!.groups[key]!)")
            }
            print("printed")
        }
        print("Dashboard Controller viewWillAppear")
        navigationController?.setNavigationBarHidden(false, animated: true)
        //if the view appears and the userObj is initialized, retrieve groups. This check must be made, since the first time the view appears the user will not yet be initialized. In this case, retrieve groups will be called in the completion block of authenticateUser()
        if initializationComplete {
            retrieveGroups()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        removeObservers()
    }
    
    //MARK: - Table View Functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath) as! GroupCell
        let groupInfo = self.groups[indexPath.row]
        cell.groupTitleLabel.text = groupInfo.title
        cell.lastMessageLabel.text = groupInfo.lastMessage
        cell.timestampLabel.text = formatTime(timestamp: groupInfo.timestamp)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
    }
    
    //MARK: - User / Database Functions
    
    //format timestamps stored in Firebase to human readable time
    func formatTime(timestamp: Double) -> String {
        let currentTime = Date().timeIntervalSince1970
        let lastMessageDate = Date(timeIntervalSince1970: timestamp)
        let time = self.formatter.string(from: lastMessageDate)
        let dateTime = time.split(separator: ";")
        
        let timeDifference = currentTime - timestamp
        
        //if the timestamp is from more than 24 hours in the past, display a date rather than a time
        if timeDifference > 86400 {
            return String(dateTime[0])
        } else {
            return String(dateTime[1])
        }
    }
    
    func authenticateUser() {
        print("authenticate user called")
        print("uid: \(user!.uid)")
        
        //reset groups array when user is authenticated (in case there was previously a different user logged in)
        self.groups = [GroupInfo]()
        
        ref.child("users/\(user!.uid)").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                let userData = snapshot.value as! Dictionary<String,AnyObject>
                self.userObj = MyUser(email: userData["email"] as? String ?? "", password: userData["password"] as? String ?? "", uid: userData["uid"] as? String ?? "", username: userData["username"] as? String ?? "", groups: userData["groups"] as? Dictionary<String,String> ?? Dictionary<String,String>())
                print("user authenticated")
                self.initializationComplete = true
                self.retrieveGroups()
            } else {
                print("user not found")
            }
        }
        
    }
    
    func retrieveGroups() {
        self.numberGroups = self.userObj!.groups.count
        
        for (id, _) in self.userObj!.groups {
            print("id: \(id)")
            let groupHandle = self.ref.child("groups/\(id)").observe(.value, with: { (snapshot) in
                if let data = snapshot.value as? Dictionary<String,String> {
                    let groupInfo = GroupInfo(id: data["id"] ?? "", title: data["title"] ?? "", lastMessage: data["lastMessage"] ?? "", timestamp: Double(data["timestamp"] ?? "") ?? 0, profileImageURL: data["profileImageURL"] ?? "")
                    
                    //check if user is already in the group, replace the groupInfo with updated data if they are
                    if let existingGroupIndex = self.groups.index(where: { $0.id == groupInfo.id }) {
                        print("Note: already in group")
                        self.groups[existingGroupIndex] = groupInfo
                    }  else {
                        print("appending")
                        self.groups.append(groupInfo)
                    }
                    
                    if self.groups.count == self.numberGroups {
                        print("all groups retrieved, sorting")
                        self.groups.sort(by: self.sortGroupInfo(this:that:))
                        self.groupTableView.reloadData()
                    }
                } else {
                    //error
                    print("DashboardController: Error retreiving group data")
                }
            })
            
            //store observer handles so that they can all be removed when view disappears
            self.groupHandles[id] = groupHandle
        }
    }
    
    //called when view disappears
    func removeObservers() {
        for (id,handle) in self.groupHandles {
            ref.child("groups/\(id)").removeObserver(withHandle: handle)
        }
        //reset groupHandles
        self.groupHandles.removeAll()
    }
    
    //sort groups by timestamp
    func sortGroupInfo(this: GroupInfo, that: GroupInfo) -> Bool {
        return this.timestamp > that.timestamp
    }
    
    // MARK: - Navigation
    
    //logout user
    @IBAction func logoutButtonPressed(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            print("Logout Successful!")
        } catch {
            print("Logout: there's a problem")
        }
    }
    
    override func  prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "dashToAdd" {
            let destination = segue.destination as! AddGroupController
            if let userObjUnwrapped = self.userObj {
                destination.userObj = userObjUnwrapped
            }
        }
    }

}
