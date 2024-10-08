//
//  TableViewCell.swift
//  ScholarSync-Adam
//
//  Created by Adam on 8/19/24.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    var data: Scholarship!
    
    @IBOutlet weak var endingSoonLabel: UILabel!
    @IBOutlet weak var deadlineLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!    
    @IBOutlet weak var gradeLevelLabel: UILabel!
    @IBOutlet weak var endingSoonButton: UIButton!
    @IBOutlet weak var favoritesButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func favoritesButton_tapHandler(_ sender: Any) {
        data.favorite = !data.favorite    
        setFavorites()
        ScrapeService.shared.updateFavorites(item: data)
    }
    
    func setFavorites() {
        if !data.favorite {
            favoritesButton.setImage(UIImage(systemName: "heart"), for: .normal)
        } else {
            favoritesButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        }
    }
}
