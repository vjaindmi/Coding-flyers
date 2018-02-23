//
//  UploadViewController.swift
//  Siri
//
//  Created by Ishita Agarwal on 22/02/18.
//  Copyright © 2018 Sahand Edrisian. All rights reserved.
//

import UIKit
import Lottie

class UploadViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate,ResponseDelegate {
    
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var loaderView: UIView!
    @IBOutlet weak var goBtn: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var getAPicBtn: UIButton!
    let imagePicker = UIImagePickerController()
    let animationView2 : LOTAnimationView = LOTAnimationView(name: "ripple")
    let animationView3 : LOTAnimationView = LOTAnimationView(name: "dna_like_loader")

   
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        // Do any additional setup after loading the view.
        
        let animationView = LOTAnimationView(name: "beer_bubbles")
        animationView.bounds = self.view.bounds
        animationView.center = self.view.center
        animationView.contentMode = .scaleAspectFill
        animationView.loopAnimation = true
        self.view.addSubview(animationView)
        self.view.sendSubview(toBack: animationView)
        animationView.play()
        self.goBtn.isHidden = true
        self.loaderView.isHidden = true

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func getAPicBtnClicked(_ sender: Any) {
        self.tagLabel.text = ""
       let alert =  UIAlertController(title: "Get a picture to upload", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: UIAlertActionStyle.default, handler: { (action) in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "Gallery", style: UIAlertActionStyle.default, handler: { (action) in
            self.openGallery()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera() {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)

    }
    
    func openGallery() {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let pickedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        self.imageView.image = pickedImage
        dismiss(animated: true, completion: nil)
        DispatchQueue.main.async {
            self.animationView2.frame = self.goBtn.frame
            self.animationView2.center = CGPoint(x: self.goBtn.center.x, y: self.goBtn.center.y)
            self.animationView2.contentMode = .scaleAspectFill
            self.animationView2.loopAnimation = true
            self.view.addSubview(self.animationView2)
            self.view.bringSubview(toFront: self.goBtn)
            self.goBtn.isHidden = false
            self.animationView2.play()
        }
        
    }
    
//    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
//        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
//            self.imageView.contentMode = .scaleAspectFit
//            self.imageView.image = pickedImage
//        }
//        dismiss(animated: true, completion: nil)
//    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func goBtnClicked(_ sender: Any)
    {
        animationView2.isHidden = true
        self.loaderView.isHidden = false
        animationView3.bounds = self.view.bounds
        animationView3.center = self.view.center
        animationView3.contentMode = .scaleAspectFit
        animationView3.loopAnimation = true
        self.view.addSubview(animationView3)
        animationView3.play()
        SiriRequestMethods.sharedInstance.delegate = self
        SiriRequestMethods.sharedInstance.uploadImage(imageData: UIImageJPEGRepresentation(self.imageView.image!, 1.0)!) {
            
        }
    }
    
    
    func responseReceived(data: NSDictionary) {
        
        animationView3.isHidden = true
        self.loaderView.isHidden = true
        let tags = data.object(forKey: "message") as! String
        self.tagLabel.text = tags
        
    }
}
