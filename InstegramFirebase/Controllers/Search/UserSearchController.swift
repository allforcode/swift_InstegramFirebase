//
//  SearchController.swift
//  InstegramFirebase
//
//  Created by Paul Dong on 7/04/18.
//  Copyright © 2018 Paul Dong. All rights reserved.
//

import UIKit
import Firebase

class UserSearchController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    let cellId = "cellId"
    var userHasFetched = false
    var users = [User]()
    var searchedUsers = [User]()
    
    lazy var searchBar: UISearchBar = {
        let s = UISearchBar()
        s.placeholder = "Enter Username"
        s.delegate = self
        return s
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .onDrag
        collectionView?.register(UserSearchCell.self, forCellWithReuseIdentifier: cellId)
        setSearchBar()
    }
    
    private func setSearchBar(){
        navigationItem.titleView = searchBar
        //set search bar background color
        guard let UISearchBarTextField: AnyClass = NSClassFromString("UISearchBarTextField") else { return }
        for view in searchBar.subviews {
            view.backgroundColor = UIColor.clear
            for subview in view.subviews {
                if subview.isKind(of: UISearchBarTextField) {
                    subview.backgroundColor = UIColor.rgb(230)
                }
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserSearchCell
        cell.user = self.searchedUsers[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 60)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.searchedUsers.count
    }
    
    private func fetchUsers(completion: (() -> Void)? = nil ){
        print("fetch users when users has \(self.users.count) items")
        Database.database().reference().child(DBChild.users.rawValue).queryOrdered(byChild: "username").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let usersDic = snapshot.value as? [String : Any] else { return }
            
            usersDic.forEach({ (key, value) in
                if key != Auth.auth().currentUser?.uid {
                    guard let userDic = value as? [String : Any] else { return }
                    let user = User(uid: key, dictionary: userDic)
                    self.users.append(user)
                }
            })
            
            guard let completion = completion else { return }
            completion()
        }) { (error) in
            print("Failed to fetch users", error)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = self.searchedUsers[indexPath.item]
        let userProfileController = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileController.user = user
        self.navigationController?.pushViewController(userProfileController, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if self.users.isEmpty && !self.userHasFetched {
            print("self.users is empty")
            self.userHasFetched = true
            self.fetchUsers {
                self.searchUser(searchText)
            }
        }else{
            print("self.users is not empty, it contains \(self.users.count) items")
            self.searchUser(searchText)
        }
    }
    
    private func searchUser(_ searchText: String ){
        self.users.forEach{ print("user: \($0.username!)")}
        self.searchedUsers.forEach{ print("searchedUser: \($0.username!)")}
        
        self.searchedUsers.removeAll()
        self.collectionView?.reloadData()
        
        self.searchedUsers = self.users.filter({ (user) -> Bool in
            guard let username = user.username else { return false }
            return username.lowercased().contains(searchText.lowercased())
        })
        
        self.collectionView?.reloadData()
    }
}
