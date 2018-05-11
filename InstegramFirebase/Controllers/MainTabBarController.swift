//
//  MainTabBarController.swift
//  InstegramFirebase
//
//  Created by Paul Dong on 10/02/18.
//  Copyright © 2018 Paul Dong. All rights reserved.
//

import UIKit
import Firebase

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        if Auth.auth().currentUser == nil {
            let loginController = LoginController()
            let navController = UINavigationController(rootViewController: loginController)
            DispatchQueue.main.async {
                self.present(navController, animated: true, completion: nil)
            }
            return
        }
        
        view.backgroundColor = .white
        tabBar.tintColor = .black
        setupViewControllers()
    }
    
    func setupViewControllers(){
        let homeController = HomeController(collectionViewLayout: UICollectionViewFlowLayout())
        let homeNavController = createController(controller: homeController, iconSelected: #imageLiteral(resourceName: "home_selected"), iconUnselected: #imageLiteral(resourceName: "home_unselected"))

        let searchController = UserSearchController(collectionViewLayout: UICollectionViewFlowLayout())
        let searchNavController = createController(controller: searchController, iconSelected: #imageLiteral(resourceName: "search_selected"), iconUnselected: #imageLiteral(resourceName: "search_unselected"))
        
        let plusController = UIViewController()
        let plusNavController = createController(controller: plusController, iconSelected: #imageLiteral(resourceName: "plus_unselected"), iconUnselected: #imageLiteral(resourceName: "plus_unselected"))
        
        let likeController = UIViewController()
        let likeNavController = createController(controller: likeController, iconSelected: #imageLiteral(resourceName: "like_selected"), iconUnselected: #imageLiteral(resourceName: "like_unselected"))
        
        let userProfileController = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())

//        if let currentUserId = Auth.auth().currentUser?.uid {
//            Database.fetchUserWithUID(currentUserId) { (user) in
//                userProfileController.user = user
//            }
//        }

        let userProfileNavController = createController(controller: userProfileController, iconSelected: #imageLiteral(resourceName: "profile_selected"), iconUnselected: #imageLiteral(resourceName: "profile_unselected"))
        
        tabBar.tintColor = .black
        
        viewControllers = [homeNavController, searchNavController, plusNavController, likeNavController, userProfileNavController,]
    }
    
    private func createController(controller: UIViewController, iconSelected: UIImage, iconUnselected: UIImage) -> UINavigationController{
        let navController = UINavigationController(rootViewController: controller)
        navController.tabBarItem.image = iconUnselected.withRenderingMode(.alwaysOriginal)
        navController.tabBarItem.selectedImage = iconSelected.withRenderingMode(.alwaysOriginal)
        navController.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
        return navController
    }
    
    //delegates
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = viewControllers?.index(of: viewController)

        if index == 2 {
            let layout = UICollectionViewFlowLayout()
            let photoSelectorController = PhotoSelectorController(collectionViewLayout: layout)
            let photoNavController = UINavigationController(rootViewController: photoSelectorController)
            present(photoNavController, animated: true, completion: nil)
        }
        return index != 2
    }
}
