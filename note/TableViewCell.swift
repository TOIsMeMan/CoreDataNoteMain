//
//  TableViewCell.swift
//  note
//
//  Created by MacBook Pro on 07/05/2024.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var detailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    func render(detail: String) {
        self.detailLabel.text = detail
    }
}
