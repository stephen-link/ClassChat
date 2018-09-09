//
//  DashboardMenuController.swift
//  ClassChat
//
//  Created by Stephen Link on 9/6/18.
//  Copyright © 2018 Stephen Link. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import SDWebImage

//extend UIImageView to allow them to be circular
extension UIImageView {
    func circular() {
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
        self.layer.borderWidth = CGFloat(3)
        self.layer.borderColor = UIColor.white.cgColor       
    }
}

class DashboardMenuController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //MARK: - Instance Variables and Outlets
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var navItem: UINavigationItem!
    
    let defaultImage = UIImage(named: "profile_default")
    
    //dashboard controller will provide a default userObj if userObj is nil, so this can be force unwrapped safely
    var userObj : MyUser!
    
    //MARK: - View Controller Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //use extension to make profileImageView circular
        profileImageView.circular()
        
        //set title
        navItem.title = userObj.username
        
        //set default image
        profileImageView.image = defaultImage
        
        retrieveProfileImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //present image picker when profileImageView is tapped
    @IBAction func profileImageViewTapped(_ sender: Any) {
        presentImagePicker()
    }
    
    //present image picker when edit button is pressed
    @IBAction func editProfileImageButtonPressed(_ sender: Any) {
        presentImagePicker()
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
            
            profileImageView.image = selectedImageUnwrapped
            setProfileImage(image: selectedImageUnwrapped)
            
        } else {
            print("ProfileViewController: Error picking profile image")
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func setProfileImage(image: UIImage) {
        let data = UIImagePNGRepresentation(image)
        let storageRef = Storage.storage().reference(withPath: "profileImages/\(userObj.uid).png")
        storageRef.putData(data!, metadata: nil, completion: { (metadata, error) in
            if error != nil {
                print("ProfileViewController: Error uploading profile image")
            } else {
                let urlData = ["profileImageURL": "\(metadata!.downloadURL()!)"]
                let userRef = Database.database().reference().child("users/\(self.userObj.uid)")
                
                userRef.updateChildValues(urlData)
                
                self.userObj.profileImageURL = metadata!.downloadURL()!.absoluteString
            }
        })
    }
    
    func retrieveProfileImage() {

        print("retrieving profile image")
        
        // create URL from user data
        let profURL = URL(string: self.userObj.profileImageURL)
        
        
        // Download, cache, and set the image with SDWebImage
        profileImageView.sd_setImage(with: profURL, placeholderImage: self.defaultImage, options:  .highPriority, completed: { (image, error, cache, url) in
            if error != nil {
                print("ProfileViewController: Error downloading profile image - 96")
                print("error: \(error!)")
                
            } else {
                print("profile image set")
            }
        })
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
