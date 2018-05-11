//
//  UserProfileController.swift
//  InstegramFirebase
//
//  Created by Paul Dong on 10/02/18.
//  Copyright © 2018 Paul Dong. All rights reserved.
//

import UIKit
import Firebase

class UserProfileController: UICollectionViewController {
    
    let headerId = "headerId"
    let cellId = "cellId"
    var posts = [Post]()

    var user: User? {
        didSet {
            log.warning("user has been set to", context: user?.username)
            self.collectionView?.reloadData()
        }
    }
    
    //MARK: overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        log.debug("current user: ", context: user?.username)
        collectionView?.backgroundColor = .white
        collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        collectionView?.register(UserProfilePhotoCell.self, forCellWithReuseIdentifier: cellId)
        
        self.fetchUser()
        self.setupLogOutButton()
    }
    
    func setupLogOutButton(){
        let gearButton = UIBarButtonItem(image: #imageLiteral(resourceName: "gear").withRenderingMode(UIImageRenderingMode.alwaysOriginal), landscapeImagePhone: #imageLiteral(resourceName: "gear"), style: .plain, target: self, action: #selector(handleLogOut))
        navigationItem.rightBarButtonItem = gearButton
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! UserProfileHeader
        log.warning("render header", context: user?.username)
        header.user = user
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserProfilePhotoCell
        cell.post = self.posts[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 3 
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    private func fetchUser() {
        var currentUserId: String?
        
        if self.user == nil {
            currentUserId = Auth.auth().currentUser?.uid
            log.warning("current user should be the login user")
        }else{
            currentUserId = self.user?.uid
            log.warning("current user should be the selected user", context: user?.username)
        }
        
        guard let uid = currentUserId else { return }
        
        Database.fetchUserWithUID(uid) { (user) in
            self.user = user
            DispatchQueue.main.async {
                self.navigationItem.title = user.username
                self.collectionView?.reloadData()
            }
            self.fetchOrderedPosts(user: user)
        }
    }
    
    private func fetchOrderedPosts(user: User){
        guard let uid = user.uid else { return }
        let postRef = Database.database().reference().child(DBChild.posts.rawValue).child(uid).queryOrdered(byChild: "creationDate")
        
        postRef.observe(.childAdded, with: { ( snapshot ) in
            guard var postDic = snapshot.value as? [String: Any] else { return }
            postDic["user"] = self.user
            let post = Post(dictionary: postDic)
            self.posts.insert(post, at: 0)
            
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }) { ( error ) in
            log.error("Failed to fetch posts", context: error)
            return
        }
    }
    
    @objc private func handleLogOut(){
        let alertController = UIAlertController()
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { ( _ ) in
            do {
                try Auth.auth().signOut()
                let loginController = LoginController()
                let navController = UINavigationController(rootViewController: loginController)
                DispatchQueue.main.async {
                    self.present(navController, animated: true, completion: nil)
                }
            } catch let error {
                log.error("Failed to sign out", context: error)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
