//
//  NewGroupViewController.swift
//  groupCycle
//
//  Created by River McCaine on 3/12/21.
//

import UIKit
import JGProgressHUD

class NewGroupViewController: UIViewController {
    // MARK: - Propeties
    public var completion: ((SearchResult) -> (Void))?
    private var users = [[String: String]]()
    private var hasFetched = false
    private var results = [SearchResult]()

    // MARK: - View Items
    private let spinner = JGProgressHUD(style: .dark)
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for users..."
        return searchBar
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(NewGroupCell.self, forCellReuseIdentifier: NewGroupCell.identifier)
        return table
    }()
    
    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "No results"
        label.textAlignment = .center
        label.textColor = .green
        label.font = .systemFont(ofSize: 21, weight: .medium)
        
        return label
    }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(noResultsLabel)
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate = self
        view.backgroundColor = .white
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissSelf))
        
        searchBar.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noResultsLabel.frame = CGRect(x: view.width / 4, y: (view.height-200) / 2, width: view.width / 2, height: 200)
    }
    
    // MARK: - Helper Methods
    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
    
} // END OF CLASS

// MARK: - Extensions
extension NewGroupViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.isEmpty, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        
        searchBar.resignFirstResponder()
        
        results.removeAll()
        spinner.show(in: view)
        
        searchUsers(query: text)
    }
    /// User Search Functionality
    func searchUsers(query: String) {
        // check if array has fire base results
        if hasFetched {
            // if it does: filter
            filterUsers(with: query)

        } else {
            // if not, fetch then filter.
            DatabaseManager.shared.getAllUsers(completion: { [weak self] result in
                switch result {
                case .success(let usersCollection):
                    self?.hasFetched = true
                    self?.users = usersCollection
                    self?.filterUsers(with: query)
                case .failure(let error):
                    print("Failed to get users: \(error)")
                }
            })
        }
    }
    
    func filterUsers(with term: String) {
        //update UI -> results/no results label
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String, hasFetched else {
            return
        }

        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)

        self.spinner.dismiss()

        let results: [SearchResult] = users.filter({
            guard let email = $0["email"], email != safeEmail else {
                return false
            }

            guard let name = $0["name"]?.lowercased() else {
                return false
            }

            return name.hasPrefix(term.lowercased())
        }).compactMap({

            guard let email = $0["email"],
                let name = $0["name"] else {
                return nil
            }

            return SearchResult(name: name, email: email)
        })

        self.results = results

        updateUI()
    }
    
    // MARK: - Helper Methods
    func updateUI() {
        if results.isEmpty {
            self.noResultsLabel.isHidden = false
            self.tableView.isHidden = true
        } else {
            self.noResultsLabel.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
    
} // END OF EXTENSION

// MARK: - TableView Delegate & Data Source
extension NewGroupViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = results[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: NewGroupCell.identifier, for: indexPath) as! NewGroupCell
        
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let targetUserData = results[indexPath.row]
        
        dismiss(animated: true, completion: { [weak self] in
            self?.completion?(targetUserData)
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
} // END OF EXTENSION

