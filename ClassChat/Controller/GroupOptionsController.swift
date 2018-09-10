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

        retrieveGroupImage()
        
        navItem.title = group.title
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Image Picker Functions
    
    @IBAction func editGroupImagePressed(_ sender: Any) {
        presentImagePicker()
    }
    
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
    
    func setGroupImage(image: UIImage) {
        let data = UIImagePNGRepresentation(image)
        let storageRef = Storage.storage().reference(withPath: "groupImages/\(group.id).png")
        storageRef.putData(data!, metadata: nil, completion: { (metadata, error) in
            if error != nil {
                print("ProfileViewController: Error uploading profile image")
            } else {
                let urlData = ["groupImageURL": "\(metadata!.downloadURL()!)"]
                let groupRef = Database.database().reference().child("groups/\(self.group.id)")
                
                groupRef.updateChildValues(urlData)
                
            }
        })
    }
    
    func retrieveGroupImage() {
        let url = URL(string: group.groupImageURL)
        
        //set the profile image with the url from the user who sent the message. If they haven't set a profile image, the "profile_default" image will be displayed
        groupImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "profile_default"), options:  .highPriority, completed: { (image, error, cache, url) in
            if error != nil {
                print("GroupOptionsController: error retrieving groupImage")
                print("Error: \(error!)")
            }
        })
    }

}
