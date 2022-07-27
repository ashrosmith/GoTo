//
//  CollectionViewController.swift
//  GoTo
//
//  Created by Ashley Smith on 5/17/22.
//

import UIKit
import CoreData


private let reuseIdentifier = "recipeCell"

class CollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
   
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var recipes: [RecipeData]?
    let sectionInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    let itemsPerRow: CGFloat = 2

    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "RecipeCollectionViewCell", bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: reuseIdentifier)
        self.tabBarController?.navigationItem.hidesBackButton = true
        hideKeyboardWhenTappedAround()
        loadRecipes()
    }

//MARK: - Collection View Data Source
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recipes?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! RecipeCollectionViewCell
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = cell.layer.frame.width * 0.2
        cell.recipeLabel.text = recipes?[indexPath.row].name
        if let imageData = recipes?[indexPath.row].imageData as Data? {
            cell.recipeImageView.image = UIImage(data: imageData)
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if (kind == UICollectionView.elementKindSectionHeader) {
                let headerView:UICollectionReusableView =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "collectionViewHeader", for: indexPath)
                return headerView
            }
            return UICollectionReusableView()
       }
    
//MARK: - Collection View Layout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = collectionView.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
  
//MARK: - Collection View Delegate
       
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "goToWebView", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! RecipeWebViewController
        if let indexPath = collectionView.indexPathsForSelectedItems?.first {
            if let recipe = recipes?[indexPath.row] {
                destinationVC.urlString = recipe.urlString!
                destinationVC.recipe = recipe
            }
        }
    }
    
//MARK: - Core Data Methods
    
    public func loadRecipes(with request: NSFetchRequest<RecipeData> = RecipeData.fetchRequest()) {
        do {
            recipes = try context.fetch(request)
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        } catch {
            print("Error loading recipe data, \(error).")
        }
    }

    public func createRecipe(name: String, url: String, imageData: NSData, date: Date) {
        let newItem = RecipeData(context: context)
        newItem.name = name
        newItem.urlString = url
        newItem.createdAt = date
        newItem.imageData = imageData

        do {
            try context.save()
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        } catch {
            print("Error saving new recipe, \(error).")
        }
    }

    public func deleteRecipe(recipe: RecipeData) {
        context.delete(recipe)
        
        do {
            try context.save()
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        } catch {
            print("Error deleting recipe, \(error).")
        }
    }
}


//MARK: - Search Bar Delegate

extension CollectionViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.searchTextField.textColor = UIColor.black
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<RecipeData> = RecipeData.fetchRequest()
        let predicate = NSPredicate(format:"name CONTAINS %@", searchBar.text!)
        
        request.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key:"name", ascending: true)
        request.sortDescriptors = [sortDescriptor]
       
        loadRecipes(with: request)
        collectionView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadRecipes()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

//MARK: - Hide Keyboard Method

extension CollectionViewController {
    
    private func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CollectionViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

