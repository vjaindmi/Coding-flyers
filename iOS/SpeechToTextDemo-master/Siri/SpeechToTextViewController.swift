//
//  ViewController.swift
//  Siri
//

//

import UIKit
import Speech
import Lottie




class SpeechToTextViewController: UIViewController, SFSpeechRecognizerDelegate,ResponseDelegate,UITextViewDelegate {
  
    
	
    @IBOutlet weak var loaderView: UIView!
    @IBOutlet weak var goBtn: UIButton!
    @IBOutlet weak var textView: UITextView!
	@IBOutlet weak var microphoneButton: UIButton!
    var animationView : LOTAnimationView = LOTAnimationView(name: "beer_bubbles")
    var animationView1 : LOTAnimationView = LOTAnimationView(name: "material_wave_loading")
    var animationView2 : LOTAnimationView = LOTAnimationView(name: "ripple")
    let animationView3 : LOTAnimationView = LOTAnimationView(name: "dna_like_loader")

    @IBOutlet weak var micView: UIView!
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-IN"))! //en-US
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
	override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        self.loaderView.isHidden = true
        self.loadAnimations()
        microphoneButton.isEnabled = false
        
        speechRecognizer.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            var isButtonEnabled = false
            
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.microphoneButton.isEnabled = isButtonEnabled
            }
        }
	}
    
    func loadAnimations() {
        animationView.bounds = self.view.bounds
        animationView.center = self.view.center
        animationView.contentMode = .scaleAspectFill
        animationView.loopAnimation = true
        self.view.addSubview(animationView)
        self.view.sendSubview(toBack: animationView)
        animationView.play()
        
        
        animationView1.frame = self.micView.frame
        animationView1.contentMode = .scaleToFill
        animationView1.loopAnimation = true
        self.view.addSubview(animationView1)
        
        animationView2.frame = self.goBtn.frame
        animationView2.center = CGPoint(x: self.goBtn.center.x+30, y: self.goBtn.center.y)
        animationView2.contentMode = .scaleAspectFill
        animationView2.loopAnimation = true
        self.view.addSubview(animationView2)
        self.view.bringSubview(toFront: self.goBtn)
        animationView2.isHidden = true
        self.goBtn.isHidden = true
        
        
        
    }

	@IBAction func microphoneTapped(_ sender: AnyObject) {
        if audioEngine.isRunning {
            self.stopRecording()
//            audioEngine.stop()
//            recognitionRequest?.endAudio()
            microphoneButton.isEnabled = false
            microphoneButton.setImage(UIImage(named: "mic"), for: .normal)
            animationView1.pause()
            self.goBtn.isHidden = false
            animationView2.isHidden = false
            animationView2.play()

        } else {
            textView.text = ""
            animationView2.isHidden = true
            self.goBtn.isHidden = true
            startRecording()
            animationView1.play()
            microphoneButton.setImage(UIImage(named: "micRecording"), for: .normal)
        }
	}

    func startRecording() {
        
        if recognitionTask != nil {  //1
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()  //2
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()  //3
        
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }  //4
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        } //5
        
        recognitionRequest.shouldReportPartialResults = true  //6
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in  //7
            
            var isFinal = false  //8
            
            if result != nil {
                
                self.textView.text = result?.bestTranscription.formattedString  //9
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {  //10
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.microphoneButton.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)  //11
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()  //12
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        
    }
    
    func stopRecording(){
        DispatchQueue.main.async {
            if self.audioEngine.isRunning {
                self.audioEngine.inputNode?.removeTap(onBus: 0)
                self.audioEngine.inputNode?.reset()
                self.audioEngine.stop()
                self.recognitionRequest?.endAudio()
                self.recognitionTask?.cancel()
                self.recognitionTask = nil
                self.recognitionRequest = nil
            }
        }
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            microphoneButton.isEnabled = true
        } else {
            microphoneButton.isEnabled = false
        }
    }
    
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
        var strToPass = textView.text
        
        strToPass = (strToPass?.count as! Int)>0 ? strToPass : "Hello"
        SiriRequestMethods.sharedInstance.fetchImagesFor(_text: strToPass!) { (_) in
            
        }        
    }
    
    
    func loadResponseView(data : NSDictionary){
        let queryString = data.object(forKey: "query") as? String

        if queryString == "No Response" {
           let alertVC =  UIAlertController(title: "", message: "We couldn't find appropriate response for your inputs.Please try again.", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: { (action) in
                self.animationView3.removeFromSuperview()
                self.loaderView.isHidden = true
            }))
            self.present(alertVC, animated: true, completion: nil)
        }
        else {
            let dataArray = data.object(forKey: "entities") as! NSArray
            let intent = dataArray.firstObject as?  NSDictionary
            let action = (dataArray.lastObject as? NSDictionary)
            if intent?.object(forKey: "image") is NSNull && action?.object(forKey: "image") is NSNull {
                let alertVC =  UIAlertController(title: "", message: "We couldn't find appropriate response for your inputs.Please try again.", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: { (action) in
                    self.animationView3.removeFromSuperview()
                    self.loaderView.isHidden = true
                }))
                self.present(alertVC, animated: true, completion: nil)
                
            }
            else {
                let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
                let showVC : ResponseViewController = storyBoard.instantiateViewController(withIdentifier: "ResponseViewController") as! ResponseViewController
                showVC.query = queryString
                showVC.entityIntent = intent
                showVC.entityAction = action
                self.navigationController?.pushViewController(showVC, animated: true);

            }
            
        }
    }
    
    
    func responseReceived(data: NSDictionary) {
        DispatchQueue.main.async {
            self.loadResponseView(data: data)
        }
        
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            self.goBtn.isHidden = false
            animationView2.isHidden = false
            animationView2.play()
            return false
        }
        return true
    }
    
}

