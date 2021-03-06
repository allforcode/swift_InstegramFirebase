//
//  UserProfileController.swift
//  InstegramFirebase
//
//  Created by Paul Dong on 10/02/18.
//  Copyright © 2018 Paul Dong. All rights reserved.
//

import UIKit
import Firebase

class UserProfileController: UICollectionViewController, UserProfileViewDelegate {
    
    let headerId = "headerId"
    let gridCellId = "gridCellId"
    let listCellId = "listCellId"
    var posts = [Post]()
    var isGridView = true
    var lastFetchedPostCreationDate: TimeInterval?
    var isFinishFetching: Bool = false
    
    var user: User? {
        didSet {
            log.warning("user has been set to", context: user?.username)
            guard let user = self.user else { return }
            fetchPaginatePosts(user: user)
//            self.collectionView?.reloadData()
        }
    }
    
    //MARK: overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        log.debug("current user: ", context: user?.username)
        collectionView?.backgroundColor = .white
        collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        collectionView?.register(UserProfilePhotoCell.self, forCellWithReuseIdentifier: gridCellId)
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: listCellId)
        
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
        header.delegate = self
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == 0 {
            log.warning("post at cellForItemAt: ", context: self.posts[indexPath.item])
        }

        if let user = self.user, indexPath.item == self.posts.count - 1, !isFinishFetching {
            log.warning("fetch paginate post", context: indexPath.item)
            fetchPaginatePosts(user: user)
        }
        
        if isGridView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: gridCellId, for: indexPath) as! UserProfilePhotoCell
            cell.post = self.posts[indexPath.item]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: listCellId, for: indexPath) as! HomePostCell
//            cell.delegate = self
            cell.post = self.posts[indexPath.item]
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = isGridView ? (view.frame.width - 2) / 3 : view.frame.width
        let homeCellUserProfileImageHeight: CGFloat = 8 + 40 + 8
        let homeCellPostImageHeight = homeCellUserProfileImageHeight + view.frame.width / 4 * 3
        let homeCellHeight = homeCellPostImageHeight + 8 + 50 + 8 + 80
        let height = isGridView ? width : homeCellHeight
        return CGSize(width: width, height: height)
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
//            self.fetchOrderedPosts(user: user)
        }
    }
    
    let PAGE_ITEMS_COUNT: Int = 3
    
    private func fetchPaginatePosts(user: User) {
        guard let uid = user.uid else { return }
        let postRef = Database.database().reference().child(DBChild.posts.rawValue).child(uid)
        var postQuery = postRef.queryOrdered(byChild: "creationDate")
        
//        if let lastPostId = self.lastFetchedPostId {
//            log.warning("last fetched post id is", context: lastPostId)
//            postQuery = postQuery.queryEnding(atValue: lastPostId)
//        }

        log.warning("self.posts", context: self.posts.count)
        
        if let lastCreationDate = self.lastFetchedPostCreationDate {
//            let lastPostCreationDate = self.posts.last?.creationDate?.timeIntervalSince1970
            log.warning("last post is:", context: self.lastFetchedPostCreationDate)
            postQuery = postQuery.queryEnding(atValue: lastCreationDate)
        }
        
        postQuery.queryLimited(toLast: UInt(PAGE_ITEMS_COUNT + 1)).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let postsDic = snapshot.value as? [String : Any] else { return }
            log.warning("count of dictionary of posts:", context: postsDic.count)
            
            guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
//            self.lastFetchedPostId = allObjects.removeFirst().key
            if allObjects.count == 4 {
                guard let firstPost = allObjects.removeFirst().value as? [String: Any] else { return }
                guard let creationDate = firstPost["creationDate"] as? TimeInterval else { return }
                self.lastFetchedPostCreationDate = creationDate
            }
            
            for obj in allObjects {
                log.warning("posts key", context: obj.key)
            }
            
            if allObjects.count < self.PAGE_ITEMS_COUNT {
                self.isFinishFetching = true
            }
            
            allObjects.reversed().forEach({ ( postSnapshot ) in
                guard var postDic = postSnapshot.value as? [String: Any] else { return }
                postDic["user"] = self.user
                var post = Post(dictionary: postDic)
                post.id = postSnapshot.key
                self.posts.append(post)
            })
            
            DispatchQueue.main.async {
                log.warning("reload")
                self.collectionView?.reloadData()
            }
        }) { ( error ) in
            log.error("Failed to fetch posts", context: error)
            return
        }
        
    }
    
    private func fetchOrderedPosts(user: User){
        guard let uid = user.uid else { return }
        let postRef = Database.database().reference().child(DBChild.posts.rawValue).child(uid).queryOrdered(byChild: "creationDate")
        
//        postRef.observe(.childAdded, with: { ( snapshot ) in
//            guard var postDic = snapshot.value as? [String: Any] else { return }
//            postDic["user"] = self.user
//            let post = Post(dictionary: postDic)
//            self.posts.insert(post, at: 0)
//
//            DispatchQueue.main.async {
//                log.warning("reload")
//                self.collectionView?.reloadData()
//            }
//        }) { ( error ) in
//            log.error("Failed to fetch posts", context: error)
//            return
//        }
        
        postRef.observe(.value, with: { (snapshot) in
            guard let postsDic = snapshot.value as? [String : Any] else { return }
            postsDic.forEach({ ( post ) in
                guard var postDic = post.value as? [String: Any] else { return }
                postDic["user"] = self.user
                let post = Post(dictionary: postDic)
                self.posts.insert(post, at: 0)
            })
            
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
    
    func didChangeView(_ changeTo: Int) {
        log.verbose("did change view in controller", context: changeTo)
        isGridView = changeTo == ButtonTag.grid.rawValue
        collectionView?.reloadData()
    }
}
