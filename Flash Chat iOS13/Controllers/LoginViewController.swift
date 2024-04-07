//
//  LoginViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    
    @IBAction func loginPressed(_ sender: UIButton) {
        guard let email = emailTextfield.text, let password = passwordTextfield.text else {
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) {  authResult, error in
            if let error = error {
                print(error)
            }
            else {
                self.performSegue(withIdentifier: K.loginSegue, sender: self)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = UIColor(named: K.BrandColors.lighBlue)
        navigationController?.navigationBar.scrollEdgeAppearance?.backgroundColor = UIColor(named: K.BrandColors.blue)
        navigationController?.navigationBar.standardAppearance.backgroundColor = UIColor(named: K.BrandColors.blue)
    }
    
}
