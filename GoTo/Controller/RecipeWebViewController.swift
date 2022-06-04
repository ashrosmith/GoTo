//
//  RecipeWebViewController.swift
//  GoTo
//
//  Created by Ashley Smith on 5/17/22.
//

import UIKit
import WebKit

class RecipeWebViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var recipeWebView: WKWebView!
    let collectionVC = CollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
    var urlString = String()
    var recipe: RecipeData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: urlString)
        recipeWebView.load(URLRequest(url: url!))
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        recipeWebView.loadHTMLString("", baseURL: nil)
    }
  
    @IBAction func trashButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Confirm Deletion", message: "Are you sure you want to permanently delete this recipe?", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .default) { (action) in
            self.collectionVC.deleteRecipe(recipe: self.recipe!)
            self.performSegue(withIdentifier: "goToUpdatedRecipeList", sender: self)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor(red: 0.94, green: 0.89, blue: 0.80, alpha: 1.00)
        alert.view.tintColor = UIColor.black
        alert.setValue(NSAttributedString(string: alert.title!, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.heavy), NSAttributedString.Key.foregroundColor : UIColor.black]), forKey: "attributedTitle")
        alert.setValue(NSAttributedString(string: alert.message!, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16,weight: UIFont.Weight.regular),NSAttributedString.Key.foregroundColor : UIColor.black]), forKey: "attributedMessage")
        
        self.present(alert, animated: true)
    }
}
