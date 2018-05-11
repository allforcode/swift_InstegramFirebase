//
//  HomeController.swift
//  InstegramFirebase
//
//  Created by Paul Dong on 1/04/18.
//  Copyright © 2018 Paul Dong. All rights reserved.
//

import UIKit
import Firebase

class HomeController: UICollectionViewController, UICollectionViewDelegateFlowLayout, HomePostCellDelegate {
    let homeCellId = "homeCellId"
    var posts = [Post]()
    var numberOfFollowedUsers: Int = 0
    var numberOfUserHasFetched: Int = 0
    
    static let refreshNotificationName = Notification.Name(rawValue: "refreshHomePosts")
    
    override func viewDidLoad() {
        log.verbose("view did load")
        super.viewDidLoad()
        self.collectionView?.backgroundColor = .white
        self.collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: homeCellId)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleRefresh), name: HomeController.refreshNotificationName, object: nil)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        self.collectionView?.refreshControl = refreshControl
        setupNavigationItems()
        fetchPosts()
    }
    
    @objc func handleRefresh(){
        log.verbose("handleRefresh")
        fetchPosts()
    }
    
    private func fetchPosts(){
        log.debug("start to fetch posts")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        self.posts.removeAll()
        self.collectionView?.reloadData()

        Database.fetchUserWithUID(uid) { (user) in
            log.debug("fetch posts I made")
            self.fetchPostsWithUser(user: user)
        }
        
        //fetch the users that the logined user has followed
        Database.database().reference().child(DBChild.followers.rawValue).child(uid).observe(.value, with: { (snapshot) in
            
            if let followedUserDic = snapshot.value as? [String: Bool] {
                self.numberOfFollowedUsers = followedUserDic.filter{ $0.value }.count
                self.numberOfUserHasFetched = 0
                followedUserDic.forEach({ (key, value) in
                    if value {
                        Database.fetchUserWithUID(key, completion: { (user) in
                            log.debug("fetch post for \(user.username ?? "")")
                            self.fetchPostsWithUser(user: user)
                        })
                    }
                })

                log.warning("followers", context: followedUserDic)
            }
        }) { (error) in
            log.error("Failed to fetch followers", context: error)
        }
    }
    
    private func fetchPostsWithUser(user: User){
        log.debug("start fetching", context: user.username)
        guard let uid = user.uid else { return }
        let postsRef = Database.database().reference().child(DBChild.posts.rawValue).child(uid)
        if user.uid != Auth.auth().currentUser?.uid {
            self.numberOfUserHasFetched += 1
        }
        log.warning("numberOfUserHasFetched:", context: self.numberOfUserHasFetched)

        postsRef.observeSingleEvent(of: .value, with: { ( snapshot ) in
            guard let postsDic = snapshot.value as? [String: Any] else { return }
            log.warning("Fetched posts of \(user.username ?? "nil")", context: postsDic.count)
            postsDic.forEach({ ( key, value ) in
                guard var postDic = value as? [String : Any] else { return }
               
                postDic["user"] = user
                let post = Post(dictionary: postDic)
                self.posts.append(post)
            })
            
            if ( self.numberOfUserHasFetched == self.numberOfFollowedUsers) {
                DispatchQueue.main.async {
                    log.warning("start reload data")
                    self.collectionView?.refreshControl?.endRefreshing()
                    self.posts.sort(by: { (p1, p2) -> Bool in
                        if let p1CreationDate = p1.creationDate, let p2CreationDate = p2.creationDate {
                            return p1CreationDate.compare(p2CreationDate) == .orderedDescending
                        }
                        return false
                    })

                    self.collectionView?.reloadData()
                    if !self.posts.isEmpty {
                        self.collectionView?.scrollToItem(at: IndexPath(item: 0, section: 0), at: UICollectionViewScrollPosition.top, animated: true)
                    }
                }
            }
        }, withCancel: { ( error ) in
            log.error("Failed to fetch user's posts", context: error)
            return
        })
    }
    
    private func setupNavigationItems(){
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo2"))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "camera3").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(showCamera))
    }
    
    @objc func showCamera(){
        log.verbose("show camera")
        let cameraController = CameraController()
        present(cameraController, animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView?.dequeueReusableCell(withReuseIdentifier: homeCellId, for: indexPath) as! HomePostCell
        cell.post = self.posts[indexPath.item]
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //in HomePostCell.swift
        //40: height of userProfileImageView
        //8: padding value
        //50: icons row
        let topHeight: CGFloat = 8 + 40 + 8
        var height = topHeight + view.frame.width / 4 * 3
        height = height + 8 + 50 + 8 + 80
        return CGSize(width: view.frame.width, height: height)
    }
    
    func didTapComment(post: Post) {
        log.verbose("did tap comment")
        hidesBottomBarWhenPushed = true
        let commentController = CommentController(collectionViewLayout: UICollectionViewFlowLayout())
        commentController.post = post
        navigationController?.pushViewController(commentController, animated: true)
        hidesBottomBarWhenPushed = false
    }
}
