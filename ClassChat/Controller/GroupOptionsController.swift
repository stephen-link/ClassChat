//
//  GroupOptionsController.swift
//  ClassChat
//
//  Created by Stephen Link on 9/9/18.
//  Copyright © 2018 Stephen Link. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import SDWebImage

class GroupOptionsController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: - Instance Variables and Outlets
    
    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var navItem: UINavigationItem!
    
    var group : GroupInfo!
    
    //MARK: - View Controller Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //since this view is always dismissed directly after it is shown, retrieveGroupImage (which needs to be called everytime the view is shown) can be called in viewDidLoad rather than viewWillAppear
        retrieveGroupImage()
        
        navItem.title = group.title
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //present image picker when edit Image button is pressed
    @IBAction func editGroupImagePressed(_ sender: Any) {
        presentImagePicker()
    }
    
    //MARK: - Image Picker Functions
    
    func presentImagePicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    // When a picture is selected from picker, update profileImageView, upload image to storage, update userDB
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImage: UIImage?
        
        // Determine if selected image has been edited
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            selectedImage = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImage = originalImage
        }
        
        // set profileImageView image, upload PNG Representation of image to FIRStorage, upon completion update userDB with image URL
        if let selectedImageUnwrapped = selectedImage {
            
            groupImageView.image = selectedImageUnwrapped
            setGroupImage(image: selectedImageUnwrapped)
            
        } else {
            print("ProfileViewController: Error picking profile image")
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Group Image Functions
    
    //upload group image to Firebase Storage, and store the URL in the group object
    func setGroupImage(image: UIImage) {
        let data = UIImagePNGRepresentation(image)
        
        //upload image to Firebase Storage
        let storageRef = Storage.storage().reference(withPath: "groupImages/\(group.id).png")
        storageRef.putData(data!, metadata: nil, completion: { (metadata, error) in
            if error != nil {
                print("ProfileViewController: Error uploading profile image")
            } else {
                
                //store URL to Firebase in upload completion block
                let urlData = ["groupImageURL": "\(metadata!.downloadURL()!)"]
                let groupRef = Database.database().reference().child("groups/\(self.group.id)")
                
                groupRef.updateChildValues(urlData)
                
            }
        })
    }
    
    //download group Image using the url stored in GorupInfo, with default profile image as a default
    func retrieveGroupImage() {
        let url = URL(string: group.groupImageURL)
        
        groupImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "profile_default"), options:  .highPriority, completed: { (image, error, cache, url) in
            if error != nil {
                print("GroupOptionsController: error retrieving groupImage")
                print("Error: \(error!)")
            }
        })
    }

}
