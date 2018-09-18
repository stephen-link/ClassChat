//
//  ChatViewController.swift
//  ClassChat
//
//  Created by Stephen Link on 9/2/18.
//  Copyright © 2018 Stephen Link. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    

    //MARK: - Instance Variables and Outlets
    
    @IBOutlet weak var messageTextViewHeight: NSLayoutConstraint!
    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var inputContainerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var chatTableView: UITableView!
    
    var userObj : MyUser?
    var group : GroupInfo!
    var ref : DatabaseReference!
    var messages : [Message] = [Message]()
    var formatter : DateFormatter?
    var messageHandle : UInt?
    
    
    //MARK: - View Controller Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //initialize ref
        ref = Database.database().reference()
        
        //set chat title
        navItem.title = group.title
        
        //setup tableView
        chatTableView.delegate = self
        chatTableView.dataSource = self
        
        //this will allow the table view to automatically resize table view cells based on the length of the message
        chatTableView.rowHeight = UITableViewAutomaticDimension
        chatTableView.estimatedRowHeight = 70
        
        
        //setup textView
        messageTextView.delegate = self
        
        //Setup message input box (container view) to rise and fall with keyboard
        setupKeyboardObservers()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //retrieve messages when view appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        retrieveMessages()
    }
    
    //remove observers when the view disappears to increase efficiency
    override func viewDidDisappear(_ animated: Bool) {
        removeKeyboardObservers()
        removeDatabaseListener()
    }
    
    //send the contents of the messageTextView as a message, clear messageTextView
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        sendMessage(message: self.messageTextView.text!)
        self.messageTextView.text = ""
    }
    
    //MARK: - Table and Text View Functions
    
    //# cells = # messages
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    //populate UI with message info, they will already be sorted by timestamp due to Firebase's childByAutoID
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatTableView.dequeueReusableCell(withIdentifier: "messageCell") as! MessageCell
        cell.senderLabel.text = messages[indexPath.row].sender
        cell.messageLabel.text = messages[indexPath.row].message
        cell.timestampLabel.text = formatTime(timestamp: messages[indexPath.row].timestamp)
        
        let url = URL(string: messages[indexPath.row].profileImageURL)
        
        //set the profile image with the url from the user who sent the message. If they haven't set a profile image, the "profile_default" image will be displayed
        cell.profileImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "profile_default"), options:  .highPriority, completed: { (image, error, cache, url) in
            if error != nil {
                print("MessageViewController: error retrieving profileImage")
                print("Error: \(error!)")
            }
        })
        
        return cell
    }
    
    //when the messageTextView changes, assess whether or not the textView's size must be increased. If it increases to a threshold of 228, it will remain that size and become scrollable
    func textViewDidChange(_ textView: UITextView) {
        if containerViewHeight.constant > 228.0 {
            print("setting textView to scrollable")
            messageTextView.isScrollEnabled = true
            
            //text view needs to be resized
        } else if messageTextView.intrinsicContentSize.height > messageTextViewHeight.constant {
            print("ChatViewController: resizing message text view")
            let sizeToFitIn = CGSize(width: self.messageTextView.bounds.size.width, height: CGFloat(MAXFLOAT))
            let newSize = self.messageTextView.sizeThatFits(sizeToFitIn)
            let deltaSize = newSize.height - messageTextViewHeight.constant
            
            //increase the height of the container view by the amount the textView needs to increase
            self.containerViewHeight.constant = self.containerViewHeight.constant + deltaSize
            self.messageTextViewHeight.constant = newSize.height
            print("container view height: \(containerViewHeight.constant)")
            
        }
    }
    
    //clear the placeholder message when editing begins
    func textViewDidBeginEditing(_ textView: UITextView) {
        if messageTextView.text! == "Enter Message..." {
            messageTextView.text = ""
        }
    }
    
    //format timestamps stored in Firebase to human readable time
    func formatTime(timestamp: Double) -> String {
        
        
        let currentTime = Date().timeIntervalSince1970
        let lastMessageDate = Date(timeIntervalSince1970: timestamp)
        let time = self.formatter!.string(from: lastMessageDate)
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
    
    // MARK: - Keyboard Animation Functions
    
    //add observers for when the keyboard is hidden or showed
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    //when the keyboard shows, adjust the inputContainerView with the keyboard, clear placeholder message if not already cleared
    @objc func handleKeyboardWillShow(notification: NSNotification) {
        let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect
        inputContainerViewBottomConstraint.constant = -keyboardFrame!.height
        inputContainerViewBottomConstraint.isActive = true
        
        //if the keyboard shows and the placeholder message is in place, clear it
        if messageTextView.text! == "Enter Message..." {
            messageTextView.text = ""
        }
        
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
        UIView.animate(withDuration: duration!) {
            self.view.layoutIfNeeded()
        }
    }
    
    //when keyboard is hidden, return container view to bottom of screen and replace placeholder message
    @objc func handleKeyboardWillHide(notification: NSNotification) {
        inputContainerViewBottomConstraint.constant = 0
        inputContainerViewBottomConstraint.isActive = true
        
        //when keyboard hides, replace placeholder message
        messageTextView.text = "Enter Message..."
        
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
        UIView.animate(withDuration: duration!) {
            self.view.layoutIfNeeded()
        }
    }
    
    //remove observers when this view disappears
    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Messaging Functions
    
    //retrieve messages to be displayed in UI
    func retrieveMessages() {
        messageHandle = ref.child("messages/\(self.group.id)").observe(.childAdded, with: { (snapshot) in
            if let messageData = snapshot.value as? Dictionary<String,String> {
                
                //initialize message object with Firebase data, using empty string as a default value if it is nil
                let message = Message(sender: messageData["sender"] ?? "", message: messageData["message"] ?? "", timestamp: Double(messageData["timestamp"] ?? "") ?? 0, profileImageURL: messageData["profileImageURL"] ?? "")
                self.messages.append(message)
                self.chatTableView.reloadData()
            } else {
                print("Error retrieving messages")
            }
        })
    }
    
    //send relevant info to firebase when send button is pressed
    func sendMessage(message: String) {
        if let userObjUnW = userObj {
            let timestamp = NSDate().timeIntervalSince1970 as NSNumber
        
            // update messagesDB
            let messageData = ["message" : message, "sender" : userObjUnW.username, "senderID" : userObjUnW.uid, "timestamp" : "\(timestamp)", "profileImageURL" : userObjUnW.profileImageURL]
            ref.child("messages/\(group.id)").childByAutoId().setValue(messageData)
            
            //update groupDB
            let groupData = ["lastMessage" : "\(userObjUnW.username): \(message)", "timestamp" : "\(timestamp)"]
            ref.child("groups/\(group.id)").updateChildValues(groupData)
            
            //reset size of container view elements in case they have been resized due to the length of the message
            self.messageTextView.text = ""
            self.messageTextViewHeight.constant = 34
            self.containerViewHeight.constant = 50
            self.messageTextView.isScrollEnabled = false
        }
    }
    
    //remove database observer for efficiency
    func removeDatabaseListener() {
        if let handle = self.messageHandle {
            ref.child("messages/\(group.id)").removeObserver(withHandle: handle)
        }
    }
    
    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editGroup" {
            let destination = segue.destination as! GroupOptionsController
            destination.group = self.group
        }
    }
    
}
