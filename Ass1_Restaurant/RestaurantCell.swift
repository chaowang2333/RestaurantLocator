//
//  RestaurantCell.swift
//  Ass1_Restaurant
//
//  Created by crow on 6/9/17.
//  Copyright © 2017 ChaoWang27548848. All rights reserved.
//

import UIKit

class RestaurantCell: UITableViewCell {
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingView: RatingView!
    @IBOutlet weak var addedDateLabel: UILabel!
    @IBOutlet weak var geoCodingLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        ratingView.isUserInteractionEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
