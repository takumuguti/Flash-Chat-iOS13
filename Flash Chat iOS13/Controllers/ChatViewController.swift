//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ChatViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    let db = Firestore.firestore()
    
    var messages: [Message] = [
        //        Message(sender: "Taku", body: "Hi"),
        //        Message(sender: "Tapi", body: "How is everyone doing"),
        //        Message(sender: "Shumi", body: "Lets go to the mall"),
        //        Message(sender: "Taku", body: "no"),
        //        Message(sender: "Tapi", body: "Only if its your money."),
        //        Message(sender: "Shumi", body: "The problem is no body cares about me I am the one who is always having to ask people to do things and then you guys just say stuff like this its very upsetting and I don't like to be the one who is alwasy doing the talking say he what what he what what and yaping yaping yaping this is not fun guys you guys must do something about this I can't be always saying the same thing over and over again. At some point people are going to have to change.")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavbar()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        loadMessage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupNavbar()
    }
    func setupNavbar(){
        title = K.appName
        navigationItem.hidesBackButton = true
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance?.backgroundColor = UIColor(named: K.BrandColors.purple)
        navigationController?.navigationBar.standardAppearance.backgroundColor = UIColor(named: K.BrandColors.purple)
    }
    
    func loadMessage() {
        db.collection(K.FStore.collectionName)
            .order(by: K.FStore.dateField)
            .addSnapshotListener { (querySnapshot, error) in
            if let e = error {
                print("There was an issue retrieving the data from Firestore. \(e)")
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    self.messages = []
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let messageSender = data[K.FStore.senderField] as? String,
                            let messageBody = data[K.FStore.bodyField] as? String,
                           let messageTime = data[K.FStore.dateField] as? TimeInterval {
                            let newMessage = Message(sender: messageSender, body: messageBody, time: messageTime)
                            self.messages.append(newMessage)
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                            }
                        }
                        
                    }
                }
            }
        }
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        
        
        if let messageBody = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email {
            
            let data: [String: Any] = [K.FStore.senderField: messageSender,
                                       K.FStore.bodyField: messageBody,
                                       K.FStore.dateField: Date().timeIntervalSince1970]
            db.collection(K.FStore.collectionName).addDocument(data: data) { (error) in
                if let e = error {
                    print("There was an issue saving data to firestore, \(e)")
                }
                else {
                    DispatchQueue.main.async{
                        self.messageTextfield.text = ""
                    }
                }
            }
        }
        
        
    }
    
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        cell.label.text = message.body
        var date = Date(timeIntervalSince1970: message.time)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        let dateString = dateFormatter.string(from: date)
        print(dateString)
        //print(message.)
        cell.timeLabel.text = dateString
        if message.sender == Auth.auth().currentUser?.email {
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
            cell.label.textColor = UIColor(named: K.BrandColors.purple)
        }else{
            cell.rightImageView.isHidden = true
            cell.leftImageView.isHidden = false
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.purple)
            cell.label.textColor = UIColor(named: K.BrandColors.lightPurple)
        }
        return cell
    }
}

extension ChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
