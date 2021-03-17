//
//  ViewController.swift
//  groupCycle
//
//  Created by River McCaine on 3/12/21.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class GroupListViewController: UIViewController {
    // MARK: - View Items
    private let spinner = JGProgressHUD(style: .dark)
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self, forCellReuseIdentifier: "groupCell")
        return table
    }()
    
    private let noGroupsLabel: UILabel = {
        let label = UILabel()
        label.text = "No groups"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapComposeButton))

        
        // MARK: - Subviews
        view.addSubview(tableView)
        view.addSubview(noGroupsLabel)
        setupTableView()
        fetchGroups()
    }
    
    @objc private func didTapComposeButton() {
        let newGroup = NewGroupViewController()
        
        newGroup.completion = { [weak self] result in
            print("\(result)")
            self?.createNewConversation(result: result)
        }
        
        let navVC = UINavigationController(rootViewController: newGroup)
        present(navVC, animated: true)
    }
    
    private func createNewConversation(result: [String : String]) {
        guard let name = result["name"], let email = result["email"] else { return }
        
        let chatVC = ChatViewController(with: email)
        chatVC.isNewConversation = true
        chatVC.title = name
        chatVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(chatVC, animated: true)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
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
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func fetchGroups() {
        tableView.isHidden = false
    }
    
} // END OF CLASS

// MARK: - Extensions
extension GroupListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath)
        cell.textLabel?.text = "kingCycle"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let chatVC = ChatViewController(with: "doodoo@gmail.com")
        chatVC.title = "Mike Jones"
        chatVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(chatVC, animated: true)
        
    }
    
    
} // END OF EXTENSION

