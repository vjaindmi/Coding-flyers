//
//  MainViewController.swift
//
//  Created by Ishita Agarwal on 22/02/18.
//

import UIKit
import Lottie

class MainViewController: UIViewController {

    @IBOutlet weak var communicateView: UIView!
    @IBOutlet weak var uploadView: UIView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var communicateBtn: UIButton!
    @IBOutlet weak var uploadBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
//        uploadBtn.setTitleColor(Utility.themeColor(), for: .normal)
//        communicateBtn.setTitleColor(Utility.themeColor(), for: .normal)
        let animationView = LOTAnimationView(name: "beer_bubbles")
        animationView.bounds = self.view.bounds
        animationView.center = self.view.center
        animationView.contentMode = .scaleAspectFill
        animationView.loopAnimation = true
        bgView.addSubview(animationView)
        
        let animationView1 = LOTAnimationView(name: "confetti")
        animationView1.bounds = self.view.bounds
        animationView1.center = self.view.center
        animationView1.contentMode = .scaleAspectFit
        animationView1.loopAnimation = true
        bgView.addSubview(animationView1)
        self.view.sendSubview(toBack: bgView)
        animationView.play()
        animationView1.play()

        
        let animationView2 = LOTAnimationView(name: "camera")
        animationView2.bounds = uploadView.bounds
        animationView2.center = uploadBtn.center
        animationView2.contentMode = .scaleToFill
        animationView2.loopAnimation = true
        uploadView.addSubview(animationView2)
        animationView2.play()
        
        
        let animationView3 = LOTAnimationView(name: "collection")
        animationView3.bounds = communicateView.frame
        animationView3.center = communicateBtn.center
        animationView3.contentMode = .scaleToFill
        animationView3.loopAnimation = true
        communicateView.addSubview(animationView3)
        animationView3.play()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func uploadPictureClicked(_ sender: Any) {
        
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let uploadVC = storyBoard.instantiateViewController(withIdentifier: "UploadViewController")
        self.navigationController?.pushViewController(uploadVC, animated: true);

    }
    
    @IBAction func communicateWithKidsClicked(_ sender: Any) {
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let speechToTextVC = storyBoard.instantiateViewController(withIdentifier: "SpeechToTextViewController")
        speechToTextVC.navigationItem.hidesBackButton = false
        self.navigationController?.pushViewController(speechToTextVC, animated: true);
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
