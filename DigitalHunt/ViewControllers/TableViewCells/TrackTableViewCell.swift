//
//  TrackTableViewCell.swift
//  DigitalHunt
//
//  Created by Dave Stops on 17/10/23.
//

import UIKit

class TrackTableViewCell: UITableViewCell {
    
    //estende UItrackViewcell

    
    
    @IBOutlet weak var titleLabel: UILabel!
    //tutte le celle di tipo TracktablelViewCell avranno una label
      
    @IBOutlet weak var kidFlag: UIImageView!
       
    @IBOutlet weak var quizFlag: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
