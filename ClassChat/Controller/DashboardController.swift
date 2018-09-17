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
    var selectedGroup : GroupInfo?
    
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
    
    //There should be as many cells as there are Groups the user is a member of
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    //groupInfo objects in groups array will be already sorted by timestamp, display the information in the UI
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath) as! GroupCell
        let groupInfo = self.groups[indexPath.row]
        cell.groupTitleLabel.text = groupInfo.title
        cell.lastMessageLabel.text = groupInfo.lastMessage
        cell.timestampLabel.text = formatTime(timestamp: groupInfo.timestamp)
        
        let url = URL(string: groups[indexPath.row].groupImageURL)
        
        //set the group image with the url from the groupInfo object. If an image hasn't been set, the "profile_default" image will be displayed
        //Note: if a image has not been set, a "nil url" error will be received, but this just means the default photo will be used
        cell.groupImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "profile_default"), options:  .highPriority, completed: { (image, error, cache, url) in
            if error != nil {
                print("DashboardController: error retrieving profileImage")
                print("Error: \(error!)")
            }
        })
        
        
        return cell
    }
    
    //If a group is selected, segue to ChatViewController
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedGroup = self.groups[indexPath.row]
        performSegue(withIdentifier: "chatSelected", sender: self)
    }
    
    //MARK: - User / Database Functions
    
    //format timestamps stored in Firebase to human readable time
    func formatTime(timestamp: Double) -> String {
       
       
        let currentTime = Date().timeIntervalSince1970
        let lastMessageDate = Date(timeIntervalSince1970: timestamp)
        let time = self.formatter.string(from: lastMessageDate)
         //the formatter will date as well as time, seperated by a ;
        let dateTime = time.split(separator: ";")
        
        let timeDifference = currentTime - timestamp
        
        //if the timestamp is from more than 24 hours in the past, display a date rather than a time
        if timeDifference > 86400 {
            return String(dateTime[0])
        } else {
            return String(dateTime[1])
        }
    }
    
    //once the user is received from AppDelegate, retrieve their info from firebase
    func authenticateUser() {
        print("authenticate user called")
        print("uid: \(user!.uid)")
        
        //reset groups array when user is authenticated (in case there was previously a different user logged in)
        self.groups = [GroupInfo]()
        
        groupTableView.reloadData()
        
        ref.child("users/\(user!.uid)").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                let userData = snapshot.value as! Dictionary<String,AnyObject>
                
                //initialize userObj with data from Firebase, with default values incase they are nil
                self.userObj = MyUser(email: userData["email"] as? String ?? "", uid: userData["uid"] as? String ?? "", username: userData["username"] as? String ?? "", groups: userData["groups"] as? Dictionary<String,Bool> ?? Dictionary<String,Bool>(), profileImageURL: userData["profileImageURL"] as? String ?? "")
                print("user authenticated")
                self.initializationComplete = true
                self.retrieveGroups()
            } else {
                print("user not found")
            }
        }
        
    }
    //Retrieve group info and setup observers on the user's subscribed groups
    func retrieveGroups() {
        self.numberGroups = self.userObj!.groups.count
        
        for (id, _) in self.userObj!.groups {
            print("id: \(id)")
            let groupHandle = self.ref.child("groups/\(id)").observe(.value, with: { (snapshot) in
                if let data = snapshot.value as? Dictionary<String,String> {
                    
                    //create groupInfo struct with data from Firebase, safely unwrap the data with a default value using the nil-coalescing operator "??"
                    // in the case of the timestamp, the value must first be unwrapped as a string, then casted and unwrapped as a double
                    let groupInfo = GroupInfo(id: data["id"] ?? "", title: data["title"] ?? "", lastMessage: data["lastMessage"] ?? "", timestamp: Double(data["timestamp"] ?? "") ?? 0, groupImageURL: data["groupImageURL"] ?? "")
                    
                    //check if user is already in the group, replace the groupInfo with updated data if they are
                    if let existingGroupIndex = self.groups.index(where: { $0.id == groupInfo.id }) {
                        
                        self.groups[existingGroupIndex] = groupInfo
                    }  else {
                        print("appending \(groupInfo.title)")
                        self.groups.append(groupInfo)
                    }
                    
                    //if all groups have been retrieved and are being observed, sort the groups by timestamps, and then display in tableView
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

    //Send information to view controller based on which one is being segued to
    override func  prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "dashToAdd" {
            let destination = segue.destination as! AddGroupController
            if let userObjUnwrapped = self.userObj {
                destination.userObj = userObjUnwrapped
            }
        } else if segue.identifier == "chatSelected" {
            let destination = segue.destination as! ChatViewController
            if let userObjUnwrapped = self.userObj {
                destination.userObj = userObjUnwrapped
            }
            if let selectedGroupUnW = self.selectedGroup {
                destination.group = selectedGroupUnW
            }
            destination.formatter = self.formatter
        } else if segue.identifier == "menuOpened" {
            let destination = segue.destination as! DashboardMenuController
            if let userObjUnW = self.userObj {
                destination.userObj = userObjUnW
            } else {
                destination.userObj = MyUser()
            }
        }
    }

}
