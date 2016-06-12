//
//  NotFiledPicTableViewCell.swift
//  DoctorPlus_ios
//
//  Created by Monkey on 15/12/24.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class NotFiledPicTableViewCell: UITableViewCell {

    
    @IBOutlet weak var picImage: UIImageView!
    @IBOutlet weak var takeTime: UILabel!
    var photo:ComFqHalcyonEntityPhotoRecord!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(photo:ComFqHalcyonEntityPhotoRecord) {
        self.photo = photo
        picImage.image = UIImage.createThumbnailImageFromFile(photo.getLocalPath(), maxWidth: picImage.frame.size.width, useCache: true)
    }
}
