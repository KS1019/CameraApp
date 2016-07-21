//
//  FirstViewController.swift
//  CAMERAAPP
//
//  Created by Kotaro Suto on 2016/07/13.
//  Copyright © 2016年 Kotaro Suto. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
    
    @IBOutlet var whenLabel : UILabel?
    @IBOutlet var whoLabel : UILabel?
    @IBOutlet var wheresLabel : UILabel?
    @IBOutlet var whyLabel : UILabel?
    @IBOutlet var howLabel : UILabel?
    @IBOutlet var whatLabel : UILabel?
    
    var mainview = ViewController()
    var array = ViewController().makeSentence()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        whenLabel?.text = array[0]
        whoLabel?.text = array[1]
        wheresLabel?.text = array[2]
        whyLabel?.text = array[3]
        howLabel?.text = array[4]
        whatLabel?.text = array[5]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
