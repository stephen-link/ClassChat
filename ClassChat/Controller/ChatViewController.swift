//
//  ChatViewController.swift
//  ClassChat
//
//  Created by Stephen Link on 9/2/18.
//  Copyright © 2018 Stephen Link. All rights reserved.
//

import UIKit
import Firebase

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
        
        ref = Database.database().reference()
        
        //set chat title
        navItem.title = group.title
        
        //setup tableView
        chatTableView.delegate = self
        chatTableView.dataSource = self
        
        messageTextView.delegate = self
        
        //Setup message input box (container view) to rise and fall with keyboard
        setupKeyboardObservers()
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        retrieveMessages()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        removeKeyboardObservers()
        removeDatabaseListener()
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        sendMessage(message: self.messageTextView.text!)
        self.messageTextView.text = ""
    }
    
    
    
    //MARK: - Table and Text View Functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatTableView.dequeueReusableCell(withIdentifier: "messageCell") as! MessageCell
        cell.senderLabel.text = messages[indexPath.row].sender
        cell.messageLabel.text = messages[indexPath.row].message
        return cell
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if containerViewHeight.constant > 228.0 {
            messageTextView.isScrollEnabled = true
        } else if messageTextView.intrinsicContentSize.height > messageTextViewHeight.constant {
            print("ChatViewController: resizing message text view")
            let sizeToFitIn = CGSize(width: self.messageTextView.bounds.size.width, height: CGFloat(MAXFLOAT))
            let newSize = self.messageTextView.sizeThatFits(sizeToFitIn)
            let deltaSize = newSize.height - messageTextViewHeight.constant
            self.containerViewHeight.constant = self.containerViewHeight.constant + deltaSize
            self.messageTextViewHeight.constant = newSize.height
            print("container view height: \(containerViewHeight.constant)")
            
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if messageTextView.text! == "Enter Message..." {
            messageTextView.text = ""
        }
    }
    
    
    
    // MARK: - Keyboard Animation Functions
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func handleKeyboardWillShow(notification: NSNotification) {
        let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect
        inputContainerViewBottomConstraint.constant = -keyboardFrame!.height
        inputContainerViewBottomConstraint.isActive = true
        
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
        UIView.animate(withDuration: duration!) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func handleKeyboardWillHide(notification: NSNotification) {
        inputContainerViewBottomConstraint.constant = 0
        inputContainerViewBottomConstraint.isActive = true
        
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
        UIView.animate(withDuration: duration!) {
            self.view.layoutIfNeeded()
        }
    }
    
    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Messaging Functions
    
    func retrieveMessages() {
        messageHandle = ref.child("messages/\(self.group.id)").observe(.childAdded, with: { (snapshot) in
            if let messageData = snapshot.value as? Dictionary<String,String> {
                let message = Message(sender: messageData["sender"] ?? "", message: messageData["message"] ?? "", timestamp: Double(messageData["timestamp"] ?? "") ?? 0, profileImageURL: messageData["profileImageURL"] ?? "")
                self.messages.append(message)
                self.chatTableView.reloadData()
            } else {
                print("Error retrieving messages")
            }
        })
    }
    
    func sendMessage(message: String) {
        if let userObjUnW = userObj {
            let timestamp = NSDate().timeIntervalSince1970 as NSNumber
        
            // update messagesDB
            let messageData = ["message" : message, "sender" : userObjUnW.username, "senderID" : userObjUnW.uid, "timestamp" : "\(timestamp)"]
            ref.child("messages/\(group.id)").childByAutoId().setValue(messageData)
            
            //update groupDB
            let groupData = ["lastMessage" : message, "timestamp" : "\(timestamp)"]
            ref.child("groups/\(group.id)").updateChildValues(groupData)
        }
    }
    
    func removeDatabaseListener() {
        if let handle = self.messageHandle {
            ref.child("messages/\(group.id)").removeObserver(withHandle: handle)
        }
    }
    
}
