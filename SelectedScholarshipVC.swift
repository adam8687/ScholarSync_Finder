//
//  SelectedScholarshipVC.swift
//  ScholarSync-Adam
//
//  Created by Adam on 8/19/24.
//

import Foundation
import UIKit

class SelectedScholarshipVC: UIViewController {
    
    var scholarship: Scholarship!
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var deadlineLabel: UILabel!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var gradeLevelLabel: UILabel!
    
    @IBOutlet weak var favoritesButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        titleLabel.text = scholarship.title
        amountLabel.text = scholarship.amount
        deadlineLabel.text = scholarship.deadline
        descriptionTextView.text = scholarship.description
        gradeLevelLabel.text = scholarship.tag       
        setFavorites()
    }
    
    
    @IBAction func visitPage_tapHandler(_ sender: Any) {
        if let url = URL(string: scholarship.link) {
            UIApplication.shared.open(url, options: [:])
        }
       
    }
    
    
    @IBAction func favoritesButton_tapHandler(_ sender: Any) {
        scholarship.favorite = !scholarship.favorite
        setFavorites()
    }
    
    func setFavorites() {
        if !scholarship.favorite {
            favoritesButton.setImage(UIImage(systemName: "heart"), for: .normal)
        } else {
            favoritesButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        }
    }
}
