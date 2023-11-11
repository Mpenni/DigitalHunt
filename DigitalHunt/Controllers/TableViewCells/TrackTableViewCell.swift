//
//  TrackTableViewCell.swift
//  DigitalHunt
//
//  Created by Dave Stops on 17/10/23.
//

import UIKit

class TrackTableViewCell: UITableViewCell {
        
    @IBOutlet weak var titleLabel: UILabel!
      
    @IBOutlet weak var kidFlag: UIImageView!
       
    @IBOutlet weak var quizFlag: UIImageView!
    
    override func awakeFromNib() {  //necessaria per protocollo UITableViewCell
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
