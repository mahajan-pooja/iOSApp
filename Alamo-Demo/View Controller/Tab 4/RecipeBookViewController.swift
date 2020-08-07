//
//  RecipeBookViewController.swift
//  Alamo-Demo
//
//  Created by Pooja on 7/12/19.
//  Copyright © 2019 Pooja Mahajan. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class RecipeBookViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet weak var tblViewRecipeBook: UITableView!
    private var downloadedRecipe = [[String: Any]]()
    private var recipes = [RecipeModel]()
    private var filteredRecipes = [RecipeModel]() {
        didSet {
            DispatchQueue.main.async {
                self.tblViewRecipeBook.reloadData()
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        let user = Auth.auth().currentUser

        var email: String!
        if let user = user {
            email = user.email
        } else {
            email = KeychainWrapper.standard.string(forKey: "user-email")
        }
        Firestore.firestore().collection(email).getDocuments { querySnapshot, err in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.downloadedRecipe.removeAll()
                self.recipes.removeAll()
                self.filteredRecipes.removeAll()
                for document in querySnapshot!.documents {
                    self.downloadedRecipe.append(document.data())
                }
                
                for recipe in self.downloadedRecipe {
                    let recipeTemp = RecipeModel(fromDictionary: recipe as NSDictionary)
                    self.recipes.append(recipeTemp)
                    self.filteredRecipes = self.recipes
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredRecipes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeBookTableViewCell", for: indexPath)
        
        if let recipeBookTableViewCell = cell as? RecipeBookTableViewCell {
            recipeBookTableViewCell.lblRecipeName.text = filteredRecipes[indexPath.row].recipeName
            if filteredRecipes[indexPath.row].recipeImage != nil {
                // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
                let imageRef = Storage.storage().reference().child("images/\(filteredRecipes[indexPath.row].recipeImage!)")
                imageRef.getData(maxSize: 50 * 1024 * 1024) { data, error in
                    if let error = error {
                        print("error \(error)")
                    } else {
                        let image = UIImage(data: data!)
                        recipeBookTableViewCell.imgRecipe.image = image
                    }
                }
            } else {
                recipeBookTableViewCell.imgRecipe.image = UIImage(named: "cocktail")
            }

            Common.setShadow(view: recipeBookTableViewCell.containerUIView)
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "RecipeDetailVC")
        if let recipeDetailVC = viewController as? RecipeDetailVC {
            recipeDetailVC.recipeName = filteredRecipes[indexPath.row].recipeName
            recipeDetailVC.recipeType = filteredRecipes[indexPath.row].recipeType
            recipeDetailVC.recipeImage = filteredRecipes[indexPath.row].recipeImage
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        tableView.subviews.forEach { subview in
            if String(describing: type(of: subview)) == "UISwipeActionPullView" {
                if String(describing: type(of: subview.subviews[0])) == "UISwipeActionStandardButton" {
                    var deleteBtnFrame = subview.subviews[0].frame
                    deleteBtnFrame.origin.y = 15
                    deleteBtnFrame.size.height = 140

                    // Subview in this case is the whole edit View
                    subview.frame.origin.y -= 3
                    subview.frame.origin.x -= 20
                    subview.frame.size.height = 140
                    subview.subviews[0].frame = deleteBtnFrame
                    subview.backgroundColor = UIColor.white
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            let user = Auth.auth().currentUser
            var email: String!
            if let user = user {
                email = user.email
            } else {
                email = KeychainWrapper.standard.string(forKey: "user-email")
            }
            let document = filteredRecipes[indexPath.row].recipeName
            Firestore.firestore().collection(email).document(document!).delete { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
            recipes.remove(at: indexPath.row)
            filteredRecipes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        150
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredRecipes = searchText.isEmptyOrWhiteSpace ? recipes : recipes.filter { $0.recipeName.lowercased().contains(searchText.lowercased()) }
    }
}
