//
//  ViewController.swift
//  WebSocketExample
//
//  Created by Ahmed Lotfy on 4/27/16.
//  Copyright © 2016 Ahmed Lotfy. All rights reserved.
//

import UIKit
import Starscream
import JSQMessagesViewController

class ViewController: JSQMessagesViewController,WebSocketDelegate{
    
    private var socket:WebSocket?
    
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.lightGrayColor())
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor(red: 10/255, green: 180/255, blue: 230/255, alpha: 1.0))
    var messages = [JSQMessage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        socket = WebSocket(url: NSURL(string: "ws://localhost:8080/")!, protocols: ["chat", "superchat"])
        socket?.delegate = self
        
        self.setup()
        //        self.addDemoMessages()
    }
    
    // MARK: Websocket Delegate Methods.
    
    func websocketDidConnect(ws: WebSocket) {
        let text = "websocket is connected"
        print(text)
        //
        self.addMessage(text, SenderID: 1)
    }
    
    func websocketDidDisconnect(ws: WebSocket, error: NSError?) {
        var text = ""
        if let e = error {
            text = "websocket is disconnected: \(e.localizedDescription)"
            
        } else {
            text = "websocket disconnected"
        }
        print(text)
        //
        self.addMessage(text, SenderID: 1)
    }
    
    func websocketDidReceiveMessage(ws: WebSocket, text: String) {
        print("Received text: \(text)")
        //
        self.addMessage(text, SenderID: 0)
    }
    
    func websocketDidReceiveData(ws: WebSocket, data: NSData) {
        let text = "Received data: \(data.length)"
        print(text)
        //
        self.addMessage(text, SenderID: 0)
    }
    
    // MARK: Write Text Action
    
    func writeText(text: String) {
        socket?.writeString(text)
        //
        self.addMessage(text, SenderID: 1)
    }
    
    // MARK: Disconnect Action
    
    @IBAction func disconnect(sender: UIBarButtonItem) {
        if (socket?.isConnected) == true {
            sender.title = "Connect"
            socket?.disconnect()
        } else {
            sender.title = "Disconnect"
            socket?.connect()
        }
    }
    
    func reloadMessagesView() {
        self.collectionView?.reloadData()
    }
    
}

//MARK - Setup
extension ViewController {
    func addMessage(messageContent:String, SenderID:Int) {
        let sender = (SenderID%2 == 0) ? "Server" : self.senderId
        let message = JSQMessage(senderId: sender, displayName: sender, text: messageContent)
        self.messages += [message]
        self.reloadMessagesView()
    }
    
    func setup() {
        self.senderId = UIDevice.currentDevice().identifierForVendor?.UUIDString
        self.senderDisplayName = UIDevice.currentDevice().identifierForVendor?.UUIDString
    }
}

//MARK - Data Source
extension ViewController {
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        let data = self.messages[indexPath.row]
        return data
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didDeleteMessageAtIndexPath indexPath: NSIndexPath!) {
        self.messages.removeAtIndex(indexPath.row)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let data = messages[indexPath.row]
        switch(data.senderId) {
        case self.senderId:
            return self.outgoingBubble
        default:
            return self.incomingBubble
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
}

//MARK - Toolbar
extension ViewController {
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
//        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
//        self.messages += [message]
        self.writeText(text)
        self.finishSendingMessage()
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        
    }
}


