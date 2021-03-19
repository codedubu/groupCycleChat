//
//  ViewController.swift
//  groupCycle
//
//  Created by River McCaine on 3/12/21.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

struct Group {
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
}

struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
}

class GroupListViewController: UIViewController {
    // MARK: - View Items
    private let spinner = JGProgressHUD(style: .dark)
    
    private var groups = [Group]()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(GroupTableViewCell.self, forCellReuseIdentifier: GroupTableViewCell.identifier)
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
        startListeningForConversations()
    }
    
    private func startListeningForConversations() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        print("Starting conversation fetch...")
        DatabaseManager.shared.getAllConversations(for: safeEmail) { [weak self] (result) in
            switch result {
            case .success(let groups):
                print("Succesfully got conversation models")
                guard !groups.isEmpty  else { return }
                
                self?.groups = groups
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("Failed to get convos: \(error)")
            }
        }
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
        
        let chatVC = ChatViewController(with: email, id: nil)
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
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = groups[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: GroupTableViewCell.identifier, for: indexPath) as! GroupTableViewCell
        
        cell.configure(with: model)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = groups[indexPath.row]
        
        let chatVC = ChatViewController(with: model.otherUserEmail, id: model.id)
        
        chatVC.title = model.name
        chatVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(chatVC, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    
} // END OF EXTENSION

