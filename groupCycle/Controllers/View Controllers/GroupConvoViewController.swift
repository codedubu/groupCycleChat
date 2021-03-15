//
//  ViewController.swift
//  groupCycle
//
//  Created by River McCaine on 3/12/21.
//

import UIKit
import FirebaseAuth

class GroupConvoViewController: UIViewController {

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
        
    }
    
    // MARK: - Helper Methods
    private func validateAuth() {
        
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let loginVC = LoginViewController()
            let navVC = UINavigationController(rootViewController: loginVC)
            navVC.modalPresentationStyle = .fullScreen
            present(navVC, animated: false)
        }
    }


} // END OF CLASS

