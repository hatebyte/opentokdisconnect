//
//  ViewController.swift
//  SimpleOpenTok
//
//  Created by Scott Jones on 9/29/15.
//  Copyright © 2015 Scott Jones. All rights reserved.
//

import UIKit

class ViewController: UIViewController,CMOpenTokManagerDelegate {

    @IBOutlet weak var connectButton:UIButton?
    @IBOutlet weak var connectionStatusLabel:UILabel?
    
    var chatEngine:CMOpenTokManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpForDisconnected()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setUpForConnected() {
        self.connectButton?.setTitle("Disconnect", forState: UIControlState.Normal)
        self.connectButton?.backgroundColor = UIColor.blueColor()
        self.connectButton?.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    }
    
    func setUpForConnecting() {
        self.connectButton?.removeTarget(self, action: nil, forControlEvents: UIControlEvents.AllTouchEvents)
        self.connectButton?.addTarget(self, action: Selector("disconnectChatEngine"), forControlEvents: UIControlEvents.TouchUpInside)
        self.connectButton?.setTitle("Connecting", forState: UIControlState.Normal)
        self.connectButton?.backgroundColor = UIColor.redColor()
        self.connectButton?.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    }
    
    func setUpForDisconnected() {
        self.connectButton?.removeTarget(self, action: nil, forControlEvents: UIControlEvents.AllTouchEvents)
        self.connectButton?.addTarget(self, action: Selector("connectChatEngine"), forControlEvents: UIControlEvents.TouchUpInside)
        self.connectButton?.setTitle("Connect", forState: UIControlState.Normal)
        self.connectButton?.backgroundColor = UIColor.grayColor()
        self.connectButton?.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    }

    
    
    func connectChatEngine() {
        setUpForConnecting()
        chatEngine = CMOpenTokManager.openTokWithSession()
        chatEngine?.delegate = self
        chatEngine?.connect()
    }

    func disconnectChatEngine() {
        setUpForDisconnected()
        if let ce = self.chatEngine {
            ce.disconnect()
        }
    }

    // MARK: CMOpenTokManager
    func openTokHasConnected() {
        setUpForConnected()
        self.connectionStatusLabel?.text                                    = "Sweet connected!"
    }
    
    func openTokDisconnectedWithError(error:NSError) {
        setUpForDisconnected()
        if let _ = self.chatEngine {
            self.chatEngine                                                 = nil
        }
        self.connectionStatusLabel?.text                                    = "Now disconnected with errror"

        print("error : \(error)");
    }
    
    func openTokDidDisconnect() {
        setUpForDisconnected()
        self.connectionStatusLabel?.text                                    = "Now disconnected"
        if let _ = self.chatEngine {
            self.chatEngine                                                 = nil
        }
    }

}

