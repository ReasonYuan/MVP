//
//  AddAttachmentTableViewCell.swift
//  
//
//  Created by Nan on 15/9/6.
//
//

import UIKit

protocol AttachmentItemDeleget:NSObjectProtocol{
    func itemRemove(indexPath:NSIndexPath)
}

class AddAttachmentTableViewCell: UITableViewCell {

    @IBOutlet weak var imageView1: UIImageView!
  
    @IBOutlet weak var btnRemove: UIButton!
    
    @IBOutlet weak var button: UIButton!
    
    @IBOutlet weak var progressLabel: UILabel!
    
    weak var deleget:AttachmentItemDeleget!
    
    var photo:ComFqHalcyonEntityPhotoRecord!
    
    var indexPath:NSIndexPath!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imageView1.layer.borderColor = UIColor.grayColor().CGColor
        imageView1.layer.borderWidth = 1.0
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //删除事件
    @IBAction func onRemoveClick(sender: AnyObject) {
        deleget.itemRemove(indexPath)
    }
}
