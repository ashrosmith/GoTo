//
//  AddRecipeViewController.swift
//  GoTo
//
//  Created by Ashley Smith on 5/17/22.
//

import UIKit
import Vision

class AddRecipeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var recipeName: UITextField!
    @IBOutlet weak var recipeURL: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let collectionVC = CollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
    let imagePicker = UIImagePickerController()
    var imageData = Data()
    var recipeImageSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        let tap: UIGestureRecognizer = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
   
//MARK: - Camera Method
    
    @IBAction func cameraButtonPressed(_ sender: UIButton) {
        present(imagePicker, animated: true, completion: nil)
    }
    
//MARK: - Image Picker Controller Method
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("Error with user photo selection.")
        }
        
        imageView.image = userPickedImage
        prepareForSaving(image: userPickedImage)
        recipeImageSelected = true
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
        
//MARK: - Save Image Method
    
    func prepareForSaving(image: UIImage) {
        guard let imageJpeg  = image.jpegData(compressionQuality: 0.7) else {
            fatalError("Could not save image jpeg data.")
        }
         
        imageData = imageJpeg
    }
                  
 //MARK: - Save and Exit Methods
   
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        let date = Date()
        guard let name = recipeName.text, !name.isEmpty else {
            displayAlertMessage(userMessage: "Please enter a name for this recipe.")
                return
        }
        guard let url = recipeURL.text, !url.isEmpty else {
            displayAlertMessage(userMessage: "Please paste the website url for this recipe.")
                return
           }
        if recipeImageSelected != true {
            displayAlertMessage(userMessage: "Please select a photo for this recipe.")
        }
    
        collectionVC.createRecipe(name: name, url: url, imageData: imageData as NSData, date: date)
        goToRecipeList()
    }
    
    func goToRecipeList() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "goToRecipeList", sender: self)
        }
    }
    
//MARK: - Alert Message Method
    
    func displayAlertMessage(userMessage:String) {
        let alert = UIAlertController(title: "Error", message: userMessage, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okAction)
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor(red: 0.94, green: 0.89, blue: 0.80, alpha: 1.00)
        alert.view.tintColor = UIColor.black
        alert.setValue(NSAttributedString(string: alert.title!, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.heavy), NSAttributedString.Key.foregroundColor : UIColor.black]), forKey: "attributedTitle")
        alert.setValue(NSAttributedString(string: alert.message!, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16,weight: UIFont.Weight.regular),NSAttributedString.Key.foregroundColor : UIColor.black]), forKey: "attributedMessage")
        self.present(alert, animated: true, completion: nil)
     }
}
