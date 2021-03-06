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
    
    let Strings = ["いいねー","素敵ですよ","いいよー","まあまあですね","うーん","いい感じですね","くぅぅぅぅ"]
    //let Strings = ["ワイルドだろぉぉ","トゥース","ファンタスティック","心配ないさー","ゲッツ"]
    var countOfStrings : Int = 0
    
    let synthesizer = AVSpeechSynthesizer()
    
    var isFrontCam = true
    
    var timeOfSelfTimer : Int = 3
    
//    let selfTimerButton : UIButton = UIButton()
//    let changeCamButton : UIButton = UIButton()
//    let flashButton : UIButton = UIButton()
    let takingButton : UIButton = UIButton()
    
    let countdownLabel : UILabel = UILabel()
    //let informationLabel : UILabel = UILabel()
    let tagsLabel : UILabel = UILabel()
    
    

    var timer : NSTimer = NSTimer()
    
    let sizeOfLabel = CGSizeMake((UIScreen.mainScreen().bounds.size.width / 4) * 3, UIScreen.mainScreen().bounds.size.height / 6)
    
    let timeOfAnimation : Float = 3
    var animatedTime : Float = 0
    var stringOfAnimationLabel = "こんにちは"
    
    //スクリーンの幅
    let screenWidth = UIScreen.mainScreen().bounds.size.width
    //スクリーンの高さ
    let screenHeight = UIScreen.mainScreen().bounds.size.height
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // 画面タップでシャッターを切るための設定
        //let tapGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapped:")
        // デリゲートをセット
        //tapGesture.delegate = self;
        // Viewに追加.
        //self.view.addGestureRecognizer(tapGesture)
        
        countOfStrings = Strings.count
        
        //print(makeSentence())
        //tagsLabel.text = makeSentence()
        //tagsLabel.fontSizeToFit()
        
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
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
        let utterance = AVSpeechUtterance(string: "3秒後にさつえいします。")
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
        
        //touchedselfTimerButton()
        //起動時、ラベルを流す
        //createAnimationOfLabel()
    }
    
    func takePicture() {
        
    }
    
    override func viewDidAppear(animated: Bool) {
//        UIView.animateWithDuration(3.0) { () -> Void in
//            self.informationLabel.alpha = 0.0
//        }
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
    

    
    func setupDisplay(){

        //ログ
        print("幅->\(screenWidth)高さ->\(screenHeight)")
        // プレビュー用のビューを生成
        preView = UIView(frame: CGRectMake(0.0, 0.0, screenWidth ,screenWidth))
        
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
        
        //previewLayer.videoGravity = AVLayerVideoGravityResize
        //previewLayer.videoGravity = AVLayerVideoGravityResizeAspect
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        // レイヤーをViewに設定
        // これを外すとプレビューが無くなる、けれど撮影はできる
        self.view.layer.addSublayer(previewLayer)
        
        session.startRunning()
        
        
        takingButton.addTarget(self, action:"touchedtakingButton", forControlEvents: .TouchUpInside)
        takingButton.frame = CGRectMake(screenWidth / 2 - 100, (screenHeight - screenWidth) / 2 + screenWidth - 50, 200, 100)
        takingButton.layer.cornerRadius = 50
        takingButton.backgroundColor = UIColor.cyanColor()
        self.view.addSubview(takingButton)
        
        
//        changeCamButton.addTarget(self, action: "touchedchangeCamButton", forControlEvents: .TouchUpInside)
//        changeCamButton.frame = CGRectMake(self.view.frame.size.width - 80, 20, 60, 60)
//        changeCamButton.backgroundColor = UIColor.clearColor()
//        changeCamButton.setTitle("●", forState: .Normal)
//        changeCamButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
//        changeCamButton.titleLabel?.font = UIFont.systemFontOfSize(60)
//        self.view.addSubview(changeCamButton)
//        
//        selfTimerButton.addTarget(self, action: "touchedselfTimerButton", forControlEvents: .TouchUpInside)
//        selfTimerButton.frame = CGRectMake(20, 20, 60, 60)
//        selfTimerButton.backgroundColor = UIColor.clearColor()
//        selfTimerButton.setTitle("●", forState: .Normal)
//        selfTimerButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
//        selfTimerButton.titleLabel?.font = UIFont.systemFontOfSize(60)
//        self.view.addSubview(selfTimerButton)
//        
//        flashButton.addTarget(self, action: "touchedflashButton", forControlEvents: .TouchUpInside)
//        flashButton.frame = CGRectMake(screenWidth / 2 - 30, 20, 60, 60)
//        flashButton.backgroundColor = UIColor.clearColor()
//        flashButton.setTitle("☀︎", forState: .Normal)
//        flashButton.setTitleColor(UIColor.cyanColor(), forState: .Normal)
//        flashButton.titleLabel?.font = UIFont.systemFontOfSize(60)
//        self.view.addSubview(flashButton)
        
        tagsLabel.frame = CGRectMake(0, screenWidth, screenWidth, 100)
        tagsLabel.textColor = UIColor.cyanColor()
        tagsLabel.backgroundColor = UIColor.clearColor()
        tagsLabel.numberOfLines = 0
        self.view.addSubview(tagsLabel)
        //tagsLabel.text = " "
        
        countdownLabel.frame = CGRectMake(self.view.bounds.width / 2 - 40, self.view.bounds.height / 2 - 40, 80, 80)
        countdownLabel.textColor = UIColor.blackColor()
        countdownLabel.backgroundColor = UIColor.clearColor()
        countdownLabel.hidden = true
        countdownLabel.textAlignment = NSTextAlignment.Center
        countdownLabel.font = UIFont.systemFontOfSize(50)
        self.view.addSubview(countdownLabel)
        
//        informationLabel.frame.size = CGSizeMake(300, 300)
//        informationLabel.center = CGPointMake(screenWidth / 2, screenHeight / 2)
//        informationLabel.text = "タップして\n写真を撮る"
//        informationLabel.backgroundColor = UIColor.clearColor()
//        informationLabel.font = UIFont.systemFontOfSize(60)
//        informationLabel.textColor = UIColor.blackColor()
//        informationLabel.textAlignment = NSTextAlignment.Center
//        informationLabel.numberOfLines = 2
//        self.view.addSubview(informationLabel)
    }
    
    func touchedtakingButton() {
        takeStillPicture()
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
//        selfTimerButton.hidden = true
//        changeCamButton.hidden = true
        
        countdownLabel.text = String(timeOfSelfTimer)
        

        
    }
    
    func touchedflashButton() {
        print(__FUNCTION__)
        
        
    }
    
    func onUpdate(timer: NSTimer) {
        countdownLabel.hidden = false
        if timeOfSelfTimer > 0 {
            print("あと\(timeOfSelfTimer)秒だよ")
    
            
            let uString = AVSpeechUtterance(string: String(timeOfSelfTimer))
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
            countdownLabel.text = String(timeOfSelfTimer)
            timeOfSelfTimer--
            
        } else if timeOfSelfTimer == 0 {
//            let englishStrings = ["nice","good"," fantastic","wow","great"]
//            let countOfEnglishStrings = englishStrings.count
//            let randomIndex = Int(arc4random_uniform(UInt32(countOfEnglishStrings)))
//            let string = englishStrings[randomIndex]
//            // 読み上げる文字列を指定する
//            let utterance = AVSpeechUtterance(string: string)
//            
//            // 読み上げの速度を指定する
//            utterance.rate = AVSpeechUtteranceDefaultSpeechRate
//            // 声の高さを指定する
//            utterance.pitchMultiplier = 1
//            // 声のボリュームを指定する
//            utterance.volume = 2.0
//            
//            let voice = AVSpeechSynthesisVoice(language:"en-US")
//            utterance.voice = voice
            
            takeStillPicture()
//            // 読み上げる
//            synthesizer.speakUtterance(utterance)
            timer.invalidate()
            
            countdownLabel.hidden = true
            timeOfSelfTimer = 3
//            selfTimerButton.hidden = false
//            changeCamButton.hidden = false
        }
    }
    
    // タップイベント.
    func tapped(sender: UITapGestureRecognizer){
        print("タップ")
        
        let randomIndex = Int(arc4random_uniform(UInt32(countOfStrings)))
        let string = Strings[randomIndex]
        
        let random = Int(arc4random_uniform(UInt32(4)))
        print("random -> \(random)")
        if random == 2 {
            print("\(string) will strat animation")
            createAnimationOfLabel()
            stringOfAnimationLabel = string
        }
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
                UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
                let imageView : UIImageView = UIImageView()
                imageView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.width)
                var cropImage = UIImage()
                cropImage = self.cropImageToSquare(image)!
                imageView.image = cropImage
                self.view.addSubview(imageView)
                UIView.animateWithDuration(2.0, animations: {
                    imageView.alpha = 0
                },completion: { finished in
                    imageView.removeFromSuperview()
                })
                
//                let button : UIButton = UIButton()
//                button.setTitle("これでOKですか？", forState: .Normal)
//                button.setTitleColor(UIColor.redColor(), forState: .Normal)
//                button.frame = CGRectMake(UIScreen.mainScreen().bounds.width / 2 - 150, 10, 300, 100)
//                button.backgroundColor = UIColor.whiteColor()
//                button.addTarget(self, action: "buttonTapped:", forControlEvents: .TouchUpInside)
//                self.view.addSubview(button)
                
                // アルバムに追加.
                UIImageWriteToSavedPhotosAlbum(cropImage, self, nil, nil)
                
            })
            
        }
    }
    
    func buttonTapped() {
        
    }
    
    //MARK: ラベル流す関数
    func createAnimationOfLabel() {
        print(__FUNCTION__)
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "createLabel:", userInfo: nil, repeats: true)
    }
    
    func createLabel(timer: NSTimer) {
        print(__FUNCTION__)
        if animatedTime <= timeOfAnimation {
            print("\(animatedTime)")
            let animationLabel : UILabel = UILabel()
            animationLabel.frame.size = sizeOfLabel
            let randomCGFloat = CGFloat(Int(arc4random_uniform(UInt32(30))))
            animationLabel.frame.origin = CGPointMake(self.view.bounds.width,randomCGFloat * 20)
            animationLabel.text = stringOfAnimationLabel
            animationLabel.textColor = UIColor.whiteColor()
            animationLabel.backgroundColor = UIColor.clearColor()
            animationLabel.textAlignment = NSTextAlignment.Center
            animationLabel.font = UIFont.systemFontOfSize(30)
            self.view.addSubview(animationLabel)
            flowingAnimation(animationLabel)
            animatedTime = animatedTime + 0.1
        } else {
            timer.invalidate()
            animatedTime = 0
        }
    }
    
    func flowingAnimation(targetLabel: UILabel){
        print(__FUNCTION__)
        UIView.animateWithDuration(3.0) { () -> Void in
            targetLabel.frame.origin = CGPointMake(-self.sizeOfLabel.width, targetLabel.frame.origin.y)
        }
        
    }
    
    func cropImageToSquare(image: UIImage) -> UIImage? {
        if image.size.width > image.size.height {
            // 横長
            print("横長")
            let cropCGImageRef = CGImageCreateWithImageInRect(image.CGImage, CGRectMake(image.size.width/2 - image.size.height/2, 0, image.size.height, image.size.height))
            
            return UIImage(CGImage: cropCGImageRef!, scale: image.scale, orientation: image.imageOrientation)
        } else if image.size.width < image.size.height {
            // 縦長
            print("縦長")
            let cropCGImageRef = CGImageCreateWithImageInRect(image.CGImage, CGRectMake(0, CGFloat((screenHeight - screenWidth) / 2), image.size.width, image.size.width))
            
            return UIImage(CGImage: cropCGImageRef!, scale: image.scale, orientation: image.imageOrientation)
        } else {
            return image
        }
    }
    
    func makeSentence() -> [String] {
        var when: [[String]] = []
        var whenString = String()
        if let csvPath = NSBundle.mainBundle().pathForResource("when", ofType: "csv") {
            var csvString=""
            do{
                csvString = try NSString(contentsOfFile: csvPath, encoding: NSUTF8StringEncoding) as String
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
            csvString.enumerateLines { (line, stop) -> () in
                when.append(line.componentsSeparatedByString(","))
                
            }
            print(when)
            whenString = when[0][createIndex(when[0].count)]
            print(whenString)
            
        }
        
        var who: [[String]] = []
        var whoString = String()
        if let csvPath = NSBundle.mainBundle().pathForResource("who", ofType: "csv") {
            var csvString=""
            do{
                csvString = try NSString(contentsOfFile: csvPath, encoding: NSUTF8StringEncoding) as String
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
            csvString.enumerateLines { (line, stop) -> () in
                who.append(line.componentsSeparatedByString(","))
                
            }
            print(who)
            whoString = who[0][createIndex(who[0].count)]
            print(whoString)
            
        }
        
        var wheres: [[String]] = []
        var wheresString = String()
        if let csvPath = NSBundle.mainBundle().pathForResource("where", ofType: "csv") {
            var csvString=""
            do{
                csvString = try NSString(contentsOfFile: csvPath, encoding: NSUTF8StringEncoding) as String
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
            csvString.enumerateLines { (line, stop) -> () in
                wheres.append(line.componentsSeparatedByString(","))
                
            }
            print(wheres)
            wheresString = wheres[0][createIndex(wheres[0].count)]
            print(wheresString)
            
        }
        
        var why: [[String]] = []
        var whyString = String()
        if let csvPath = NSBundle.mainBundle().pathForResource("why", ofType: "csv") {
            var csvString=""
            do{
                csvString = try NSString(contentsOfFile: csvPath, encoding: NSUTF8StringEncoding) as String
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
            csvString.enumerateLines { (line, stop) -> () in
                why.append(line.componentsSeparatedByString(","))
                
            }
            print(why)
            whyString = why[0][createIndex(why[0].count)]
            print(whyString)
            
        }
        
        var how: [[String]] = []
        var howString = String()
        if let csvPath = NSBundle.mainBundle().pathForResource("how", ofType: "csv") {
            var csvString=""
            do{
                csvString = try NSString(contentsOfFile: csvPath, encoding: NSUTF8StringEncoding) as String
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
            csvString.enumerateLines { (line, stop) -> () in
                how.append(line.componentsSeparatedByString(","))
                
            }
            print(how)
            howString = how[0][createIndex(how[0].count)]
            print(howString)
            
        }
        
        var what: [[String]] = []
        var whatString = String()
        if let csvPath = NSBundle.mainBundle().pathForResource("what", ofType: "csv") {
            var csvString=""
            do{
                csvString = try NSString(contentsOfFile: csvPath, encoding: NSUTF8StringEncoding) as String
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
            csvString.enumerateLines { (line, stop) -> () in
                what.append(line.componentsSeparatedByString(","))
                
            }
            print(what)
            whatString = what[0][createIndex(what[0].count)]
            print(whatString)
            
        }
        
        var sentence = [String]()
        //" #" + whenString + " #" + whoString + " #" + wheresString + " #" + whyString + " #" + howString + " #" + whatString
        sentence.append(whenString)
        sentence.append(whoString)
        sentence.append(wheresString)
        sentence.append(whyString)
        sentence.append(howString)
        sentence.append(whatString)
        
        return sentence
        
        
        
    }
    
    func createIndex(countOfArray:Int) -> Int {
        let randomIndex = Int(arc4random_uniform(UInt32(countOfArray)))
        return randomIndex
    }

}

