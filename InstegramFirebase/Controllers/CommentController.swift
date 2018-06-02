//
//  CommentController.swift
//  InstegramFirebase
//
//  Created by Paul Dong on 30/04/18.
//  Copyright © 2018 Paul Dong. All rights reserved.
//

import UIKit
import Firebase

class CommentController: UICollectionViewController, UICollectionViewDelegateFlowLayout, CommentInputAccessoryViewDelegate {
    
    var post: Post?
    let cellId = "cellId"
    var comments = [Comment]()

    
    lazy var containerView: CommentInputAccessoryView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let v = CommentInputAccessoryView(frame: frame)
        v.delegate = self
        return v
    }()
    
//    @objc private func handleSubmit(){
//        log.verbose("handle submit")
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        guard let postId = self.post?.id else { return }
//        guard let text = commentTextField.text else { return }
//
//        let value = [
//            "text": text,
//            "creationDate": Date().timeIntervalSince1970,
//            "userId": uid
//        ] as [String: Any]
//        Database.database().reference().child(DBChild.comments.rawValue).child(postId).childByAutoId().updateChildValues(value) { (error, ref) in
//
//            if let err = error {
//                log.error("Failed to save comment", context: err)
//            }
//        }
//    }
    
    func didSubmit(for comment: String) {
        log.verbose("handle submit")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let postId = self.post?.id else { return }
        
        let value = [
            "text": comment,
            "creationDate": Date().timeIntervalSince1970,
            "userId": uid
            ] as [String: Any]
        Database.database().reference().child(DBChild.comments.rawValue).child(postId).childByAutoId().updateChildValues(value) { (error, ref) in
            
            if let err = error {
                log.error("Failed to save comment", context: err)
                return
            }
            
            self.containerView.clearCommentText()
            let item = self.collectionView(self.collectionView!, numberOfItemsInSection: 0) - 1
            let lastItemIndex = IndexPath(item: item, section: 0)
            self.collectionView?.scrollToItem(at: lastItemIndex, at: UICollectionViewScrollPosition.bottom, animated: true)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView?.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CommentCell
        cell.comment = self.comments[indexPath.item]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let dummyCell = CommentCell(frame: frame)
        dummyCell.comment = self.comments[indexPath.item]
        dummyCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        let actualHeight = max(40 + 8 + 8, estimatedSize.height)
        return CGSize(width: self.view.frame.width, height: actualHeight)
    }
    
    override func viewDidLoad() {
        self.collectionView?.backgroundColor = .white
        navigationItem.title = "Comments"
        self.collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        self.collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        self.collectionView?.alwaysBounceVertical = true
        self.collectionView?.keyboardDismissMode = .interactive
        self.collectionView?.register(CommentCell.self, forCellWithReuseIdentifier: cellId)
        fetchComments()
    }
    
    private func fetchComments(){
        guard let postId = self.post?.id else { return }
        
        let postRef = Database.database().reference().child(DBChild.comments.rawValue).child(postId)
//        postRef.observe(.value, with: { (snapshot) in
//            guard let commentsDic = snapshot.value as? [String: Any] else { return }
//
//            commentsDic.forEach({ (key, value) in
//                guard let commentDic = value as? [String: Any] else { return }
//                let comment = Comment(commentDic)
//                comment.id = key
//                guard let userId = commentDic["userId"] as? String else { return }
//                Database.fetchUserWithUID(userId) { (user) in
//                    comment.user = user
//                    self.comments.append(comment)
//                }
//            })
//
//            self.collectionView?.reloadData()
//        }) { (error) in
//            log.error("Failed to fetch comments", context: error)
//            return
//        }
        
        postRef.observe(.childAdded, with: { (snapshot) in
            guard let commentDic = snapshot.value as? [String: Any] else { return }
            guard let userId = commentDic["userId"] as? String else { return }
            Database.fetchUserWithUID(userId) { (user) in
                let comment = Comment(commentDic)
                comment.id = snapshot.key
                comment.user = user
                self.comments.append(comment)
                self.collectionView?.reloadData()
            }
        }) { (error) in
            log.error("Failed to fetch comments", context: error)
            return
        }
    }
    
    override var inputAccessoryView: UIView? {
        return containerView
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
}
