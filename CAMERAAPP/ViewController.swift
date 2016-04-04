//
//  ViewController.swift
//  CAMERAAPP
//
//  Created by Kotaro Suto on 2016/04/02.
//  Copyright © 2016年 Kotaro Suto. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController,UIGestureRecognizerDelegate {
    
    var input : AVCaptureDeviceInput!
    var output : AVCaptureStillImageOutput!
    var session : AVCaptureSession!
    var preView : UIView!
    var camera : AVCaptureDevice!
    
    let Strings = ["いいねー","素敵ですよ","いいよー","まあまあですね","うーん","いい感じですね"]
    //let Strings = ["ワイルドだろぉぉ","トゥース","ファンタスティック","心配ないさー","ゲッツ"]
    var countOfStrings : Int = 0
    
    let synthesizer = AVSpeechSynthesizer()
    
    var isFrontCam = false
    
    var timeOfSelfTimer : Int = 10
    
    let selfTimerButton : UIButton = UIButton()
    let changeCamButton : UIButton = UIButton()
    let countdownLabel : UILabel = UILabel()
    
    var timer : NSTimer = NSTimer()
    
    let sizeOfLabel = CGSizeMake((UIScreen.mainScreen().bounds.size.width / 4) * 3, UIScreen.mainScreen().bounds.size.height / 6)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // 画面タップでシャッターを切るための設定
        let tapGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapped:")
        // デリゲートをセット
        tapGesture.delegate = self;
        // Viewに追加.
        self.view.addGestureRecognizer(tapGesture)
        
        countOfStrings = Strings.count
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        // スクリーン設定
        setupDisplay()
        // カメラの設定
        setupCamera()
        
        
        // 読み上げる文字列を指定する
        let utterance = AVSpeechUtterance(string: "こんにちは")
        // 読み上げの速度を指定する
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        // 声の高さを指定する
        utterance.pitchMultiplier = 1
        // 声のボリュームを指定する
        utterance.volume = 1.0
        
        let voice = AVSpeechSynthesisVoice(language:"jp-JP")
        utterance.voice = voice
        
        // 読み上げる
        synthesizer.speakUtterance(utterance)
        print("読んだ")
        
        createAnimationLabel()
    }
    // メモリ管理のため
    override func viewDidDisappear(animated: Bool) {
        // camera stop メモリ解放
        session.stopRunning()
        
        for output in session.outputs {
            session.removeOutput(output as? AVCaptureOutput)
        }
        
        for input in session.inputs {
            session.removeInput(input as? AVCaptureInput)
        }
        session = nil
        camera = nil
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func setupDisplay(){
        //スクリーンの幅
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        //スクリーンの高さ
        let screenHeight = UIScreen.mainScreen().bounds.size.height
        //ログ
        print("幅->\(screenWidth)高さ->\(screenHeight)")
        
        // プレビュー用のビューを生成
        preView = UIView(frame: CGRectMake(0.0, 0.0, screenWidth, screenHeight))
        
    }
    
    func setupCamera(){
        
        // セッション
        session = AVCaptureSession()
        
        for caputureDevice: AnyObject in AVCaptureDevice.devices() {
            if isFrontCam {
                if caputureDevice.position == AVCaptureDevicePosition.Back {
                    camera = caputureDevice as? AVCaptureDevice
                }
            } else if !isFrontCam {
                if caputureDevice.position == AVCaptureDevicePosition.Front {
                    camera = caputureDevice as? AVCaptureDevice
                }
            }
        }
        
        // カメラからの入力データ
        do {
            input = try AVCaptureDeviceInput(device: camera) as AVCaptureDeviceInput
        } catch let error as NSError {
            print(error)
        }
        
        // 入力をセッションに追加
        if(session.canAddInput(input)) {
            session.addInput(input)
        }
        
        // 静止画出力のインスタンス生成
        output = AVCaptureStillImageOutput()
        // 出力をセッションに追加
        if(session.canAddOutput(output)) {
            session.addOutput(output)
        }
        
        // セッションからプレビューを表示を
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        
        previewLayer.frame = preView.frame
        
        //        previewLayer.videoGravity = AVLayerVideoGravityResize
        //        previewLayer.videoGravity = AVLayerVideoGravityResizeAspect
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        // レイヤーをViewに設定
        // これを外すとプレビューが無くなる、けれど撮影はできる
        self.view.layer.addSublayer(previewLayer)
        
        session.startRunning()
        
        //カメラ
        
        changeCamButton.addTarget(self, action: "touchedchangeCamButton", forControlEvents: .TouchUpInside)
        changeCamButton.frame = CGRectMake(20, 20, 40, 40)
        changeCamButton.backgroundColor = UIColor.blueColor()
        self.view.addSubview(changeCamButton)
        
        selfTimerButton.addTarget(self, action: "touchedselfTimerButton", forControlEvents: .TouchUpInside)
        selfTimerButton.frame = CGRectMake(self.view.frame.size.width - 60, 20, 40, 40)
        selfTimerButton.backgroundColor = UIColor.redColor()
        self.view.addSubview(selfTimerButton)
        
        countdownLabel.frame = CGRectMake(self.view.bounds.width / 2 - 40, self.view.bounds.height / 2 - 40, 80, 80)
        countdownLabel.textColor = UIColor.blueColor()
        countdownLabel.backgroundColor = UIColor.clearColor()
        countdownLabel.hidden = true
        countdownLabel.textAlignment = NSTextAlignment.Center
        countdownLabel.font = UIFont.systemFontOfSize(50)
        self.view.addSubview(countdownLabel)
    }
    
    
    func touchedchangeCamButton() {
        print(__FUNCTION__)
        if isFrontCam {
            isFrontCam = false
        } else if !isFrontCam {
            isFrontCam = true
        }
        session.stopRunning()
        setupCamera()
    }
    
    func touchedselfTimerButton() {
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "onUpdate:", userInfo: nil, repeats: true)
        selfTimerButton.hidden = true
        
        countdownLabel.text = String(timeOfSelfTimer)
        countdownLabel.hidden = false
        

        
    }
    
    func onUpdate(timer: NSTimer) {
        if timeOfSelfTimer > 0 {
            print("あと\(timeOfSelfTimer)秒だよ")
            countdownLabel.text = String(timeOfSelfTimer)
            timeOfSelfTimer--
            if timeOfSelfTimer == 3 {
                let uString = AVSpeechUtterance(string: "わらってください")
                // 読み上げの速度を指定する
                uString.rate = AVSpeechUtteranceDefaultSpeechRate
                // 声の高さを指定する
                uString.pitchMultiplier = 1
                // 声のボリュームを指定する
                uString.volume = 1.0
                
                let voice = AVSpeechSynthesisVoice(language:"jp-JP")
                uString.voice = voice
                
                // 読み上げる
                synthesizer.speakUtterance(uString)
                
            }
        } else if timeOfSelfTimer == 0 {
            let englishStrings = ["nice","good"," fantastic"]
            let countOfEnglishStrings = englishStrings.count
            let randomIndex = Int(arc4random_uniform(UInt32(countOfEnglishStrings)))
            let string = englishStrings[randomIndex]
            // 読み上げる文字列を指定する
            let utterance = AVSpeechUtterance(string: string)
            
            // 読み上げの速度を指定する
            utterance.rate = AVSpeechUtteranceDefaultSpeechRate
            // 声の高さを指定する
            utterance.pitchMultiplier = 1
            // 声のボリュームを指定する
            utterance.volume = 2.0
            
            let voice = AVSpeechSynthesisVoice(language:"en-US")
            utterance.voice = voice
            
            takeStillPicture()
            // 読み上げる
            synthesizer.speakUtterance(utterance)
            timer.invalidate()
            
            countdownLabel.hidden = true
            timeOfSelfTimer = 10
            selfTimerButton.hidden = false
        }
    }
    
    // タップイベント.
    func tapped(sender: UITapGestureRecognizer){
        print("タップ")
        
        let randomIndex = Int(arc4random_uniform(UInt32(countOfStrings)))
        let string = Strings[randomIndex]
        // 読み上げる文字列を指定する
        let utterance = AVSpeechUtterance(string: string)
        
        // 読み上げの速度を指定する
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        // 声の高さを指定する
        utterance.pitchMultiplier = 1
        // 声のボリュームを指定する
        utterance.volume = 2.0
        
        let voice = AVSpeechSynthesisVoice(language:"jp-JP")
        utterance.voice = voice
        
        // 読み上げる
        synthesizer.speakUtterance(utterance)
        print("\(string)を読んだ")
        
        takeStillPicture()
    }
    
    func takeStillPicture(){
        
        // ビデオ出力に接続.
        if let connection:AVCaptureConnection? = output.connectionWithMediaType(AVMediaTypeVideo){
            // ビデオ出力から画像を非同期で取得
            output.captureStillImageAsynchronouslyFromConnection(connection, completionHandler: { (imageDataBuffer, error) -> Void in
                
                // 取得画像のDataBufferをJpegに変換
                let imageData:NSData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataBuffer)
                
                // JpegからUIImageを作成.
                let image:UIImage = UIImage(data: imageData)!
                
                // アルバムに追加.
                UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
                
            })
            
        }
    }
    
    //ラベル流す関数
    
    func createAnimationLabel() {
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "createLabel:", userInfo: nil, repeats: true)
    }
    
    func createLabel(timer: NSTimer) {
        let animationLabel : UILabel = UILabel()
        animationLabel.frame.size = sizeOfLabel
        let randomCGFloat = CGFloat(Int(arc4random_uniform(UInt32(30))))
        animationLabel.frame.origin = CGPointMake(self.view.bounds.width,randomCGFloat * 20)
        animationLabel.text = "こんにちは"
        self.view.addSubview(animationLabel)
        flowingAnimation(animationLabel)
    }
    
    func flowingAnimation(targetLabel: UILabel){
//        UIView.animateWithDuration(NSTimeInterval(CGFloat(6.0)),
//            animations: {() -> Void in
//                targetLabel.center = CGPoint(x: -1*self.view.bounds.width,y: targetLabel.layer.position.y);
//            }, completion: {(Bool) -> Void in
//                targetLabel.removeFromSuperview()
//        })
        
        UIView.animateWithDuration(3.0) { () -> Void in
            targetLabel.center = CGPointMake(-self.sizeOfLabel.width / 2, targetLabel.frame.origin.y)
        }
        
    }

}

