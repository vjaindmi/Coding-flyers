//
//  ResponseViewController.swift
//  Siri
//
//  Created by Ishita Agarwal on 23/02/18.
//  Copyright © 2018 Sahand Edrisian. All rights reserved.
//

import UIKit
import AVFoundation
import Lottie
import SDWebImage


class ResponseViewController: UIViewController {

    @IBOutlet weak var likeImageView_Center_Constraint: NSLayoutConstraint!
    @IBOutlet weak var entityImageView: UIImageView!
    @IBOutlet weak var actionImageView: UIImageView!
    @IBOutlet weak var childImageView: UIImageView!
    @IBOutlet weak var likeView: UIView!
    
    @IBOutlet weak var textLbl: UILabel!
    @IBOutlet weak var likeImageView: UIImageView!
    var responseData : NSDictionary?
    var query : String?
    var entityIntent : NSDictionary?
    var entityAction : NSDictionary?
    let synth = AVSpeechSynthesizer()


    
    override func viewDidLoad() {
        super.viewDidLoad()
        textLbl.text = ""
        let gestureRecognizerOne = UITapGestureRecognizer(target: self, action: #selector(tapped(_sender:)))
        entityImageView.addGestureRecognizer(gestureRecognizerOne)
        entityImageView.isUserInteractionEnabled = true
      
        let gestureRecognizerTwo = UITapGestureRecognizer(target: self, action: #selector(tapped(_sender:)))
        actionImageView.addGestureRecognizer(gestureRecognizerTwo)
        actionImageView.isUserInteractionEnabled = true

        
        let animationView = LOTAnimationView(name: "beer_bubbles")
        animationView.bounds = self.view.bounds
        animationView.center = self.view.center
        animationView.contentMode = .scaleAspectFill
        animationView.loopAnimation = true
        self.view.addSubview(animationView)
        self.view.sendSubview(toBack: animationView)
        animationView.play()
        // Do any additional setup after loading the view.
        
        childImageView.image = UIImage(named: "child")
        
        
        
        let imageIntentString = entityIntent?.object(forKey: "image") as! String
        actionImageView.sd_setImage(with: URL(string: imageIntentString), completed: nil)

        let imageActionString = entityAction?.object(forKey: "image") as! String
        entityImageView.sd_setImage(with: URL(string: imageActionString), completed: nil)

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    func tapped(_sender : UITapGestureRecognizer)
    {
        let tappedview = _sender.view
        var strToSpeak = ""
        if tappedview == self.entityImageView {
            strToSpeak = self.query!
        } else {
            strToSpeak = self.entityIntent?.object(forKey: "entity") as! String
        }
        
        textToSpeech(str: strToSpeak)
        textLbl.text = strToSpeak
    }
    @IBAction func likeClicked(_ sender: Any)
    {
        let animationView = LOTAnimationView(name: "like")
        animationView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        animationView.center = CGPoint(x: self.view.center.x, y: self.view.center.y + self.view.center.y/2)
        animationView.contentMode = .scaleAspectFill
        animationView.loopAnimation = true
        self.view.addSubview(animationView)
        animationView.play()
        
        
    }
    
    @IBAction func dislikeClicked(_ sender: Any)
    {
        let animationView = LOTAnimationView(name: "like")
        animationView.bounds = self.view.bounds
        animationView.center = self.view.center
        animationView.contentMode = .scaleAspectFill
        animationView.loopAnimation = true
        self.view.addSubview(animationView)
        animationView.play()
        
        UIView.animate(withDuration: 2, animations: {
            
        }) { (active) in
            animationView.removeFromSuperview()
        }
    }
    
    
    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    func textToSpeech(str :String )
    {
        let myUtterance = AVSpeechUtterance(string:"Helloo" )
        myUtterance.rate = 0.3
        myUtterance.volume = 1
        myUtterance.voice = AVSpeechSynthesisVoice(language: "en-IN")
        synth.speak(myUtterance)
    }
    
}
