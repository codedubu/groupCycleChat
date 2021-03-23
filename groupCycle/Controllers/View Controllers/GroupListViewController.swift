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
    
    private var loginObserver: NSObjectProtocol?
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
 
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapComposeButton))
        
        // MARK: - Subviews
        view.addSubview(tableView)
        view.addSubview(noGroupsLabel)
        setupTableView()
        startListeningForConversations()
        
        loginObserver = NotificationCenter.default.addObserver(forName: .didLoginNotification, object: nil, queue: .main) { [weak self] (_) in
            guard let strongSelf = self else { return }
            
            strongSelf.startListeningForConversations()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noGroupsLabel.frame = CGRect(x: 10, y: (view.height-100)/2, width: view.width-20, height: 100)
    }
    
    // MARK: - Helper Methods
    private func startListeningForConversations() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return }
        
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        print("Starting conversation fetch...")
        DatabaseManager.shared.getAllConversations(for: safeEmail) { [weak self] (result) in
            switch result {
            case .success(let groups):
                print("Succesfully got conversation models")
                guard !groups.isEmpty  else {
                    self?.tableView.isHidden = true
                    self?.noGroupsLabel.isHidden = false
                    return
                }
                
                self?.noGroupsLabel.isHidden = true
                self?.tableView.isHidden = false
                self?.groups = groups
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                self?.tableView.isHidden = true
                self?.noGroupsLabel.isHidden = false
                print("Failed to get convos: \(error)")
            }
        }
    }
    
    @objc private func didTapComposeButton() {
        let vc = NewGroupViewController()
        vc.completion = { [weak self] result in
            guard let strongSelf = self else {
                return
            }

            let currentConversations = strongSelf.groups

            if let targetConversation = currentConversations.first(where: {
                $0.otherUserEmail == DatabaseManager.safeEmail(emailAddress: result.email)
            }) {
                let vc = ChatViewController(with: targetConversation.otherUserEmail, id: targetConversation.id)
                vc.isNewConversation = false
                vc.title = targetConversation.name
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            }
            else {
                strongSelf.createNewConversation(result: result)
            }
        }
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    private func createNewConversation(result: SearchResult) {
        let name = result.name
        let email = DatabaseManager.safeEmail(emailAddress: result.email)
        
        // check in databse if conversation with these two user exits
        // if it does, reuse conversation id
        // otherwise use existing code
        
        DatabaseManager.shared.conversationExists(with: email) { [weak self] (result) in
            switch result {
            case .success(let conversationID):
                let chatVC = ChatViewController(with: email, id: conversationID)
                chatVC.isNewConversation = false
                chatVC.title = name
                chatVC.navigationItem.largeTitleDisplayMode = .never
                self?.navigationController?.pushViewController(chatVC, animated: true)
            case.failure(_):
                let chatVC = ChatViewController(with: email, id: nil)
                chatVC.isNewConversation = true
                chatVC.title = name
                chatVC.navigationItem.largeTitleDisplayMode = .never
                self?.navigationController?.pushViewController(chatVC, animated: true)
            }
        }
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
        openConversation(model)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func openConversation(_ model: Group) {
        let chatVC = ChatViewController(with: model.otherUserEmail, id: model.id)
        
        chatVC.title = model.name
        chatVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // begin delete
            let conversationID = groups[indexPath.row].id
            
            tableView.beginUpdates()
            
            DatabaseManager.shared.deleteConversation(conversationID: conversationID) { [weak self](success) in
                if success {
                    self?.groups.remove(at: indexPath.row)
                    
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
            
            tableView.endUpdates()
        }
    }
    
} // END OF EXTENSION

