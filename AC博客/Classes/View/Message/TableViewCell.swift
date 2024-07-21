//
//  TableViewCell.swift
//  AC博客
//
//  Created by AC on 2023/7/27.
//

import Foundation
import UIKit


import UIKit
 
class TableViewCell:UITableViewCell
{
    //消息内容视图
    var customView:UIView!
    //消息背景
    var bubbleImage:UIImageView!
    //头像
    var avatarImage:UIImageView!
    //消息数据结构
    var msgItem:MessageItem!
     
    required init?(coder: NSCoder) {
         
        super.init(coder: coder)
    }
     
    //- (void) setupInternalData
    init(data:MessageItem, reuseIdentifier cellId:String)
    {
        self.msgItem = data
        super.init(style: UITableViewCell.CellStyle.default, reuseIdentifier:cellId)
        rebuildUserInterface()
    }
     
    func rebuildUserInterface()
    {
         
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        if (self.bubbleImage == nil)
        {
            self.bubbleImage = UIImageView()
            self.addSubview(self.bubbleImage)
             
        }
         
        let type =  self.msgItem.mtype
        let width =  self.msgItem.view.frame.size.width
         
        let height =  self.msgItem.view.frame.size.height
         
        var x =  (type == ChatType.Someone) ? 0 : self.frame.size.width - width -
            self.msgItem.insets.left - self.msgItem.insets.right
         
        var y:CGFloat =  0
        //显示用户头像
        if (self.msgItem.logo != "")
        {
            let logo = self.msgItem.logo
                self.avatarImage = UIImageView()
                avatarImage.sd_setImage(with: URL(string: logo))
             
            self.avatarImage.layer.cornerRadius = 9.0
            self.avatarImage.layer.masksToBounds = true
            self.avatarImage.layer.borderColor = UIColor(white:0.0 ,alpha:0.2).cgColor
            self.avatarImage.layer.borderWidth = 1.0
             
            //别人头像，在左边，我的头像在右边
            let avatarX =  (type == ChatType.Someone) ? 2 : self.frame.size.width - 52
             
            //头像居于消息底部
            let avatarY =  height
            //set the frame correctly
            self.avatarImage.frame = CGRectMake(avatarX, avatarY, 50, 50)
            self.addSubview(self.avatarImage)
             
             
            let delta =  self.frame.size.height - (self.msgItem.insets.top + self.msgItem.insets.bottom
                + self.msgItem.view.frame.size.height)
            if (delta > 0)
            {
                y = delta
            }
            if (type == ChatType.Someone)
            {
                x += 54
            }
            if (type == ChatType.Mine)
            {
                x -= 54
            }
        }
         
        self.customView = self.msgItem.view
        self.customView.frame = CGRectMake(x + self.msgItem.insets.left, y
            + self.msgItem.insets.top, width, height)
         
        self.addSubview(self.customView)
         
        //如果是别人的消息，在左边，如果是我输入的消息，在右边
        if (type == ChatType.Someone)
        {
            self.bubbleImage.image =
            UIImage(named:("yoububble.png"))!.stretchableImage(withLeftCapWidth: 21,topCapHeight:14)
             
        }
        else {
            self.bubbleImage.image =
            UIImage(named:"mebubble.png")!.stretchableImage(withLeftCapWidth: 15, topCapHeight:14)
        }
        self.bubbleImage.frame = CGRectMake(x, y, width + self.msgItem.insets.left
            + self.msgItem.insets.right, height + self.msgItem.insets.top + self.msgItem.insets.bottom)
    }
}
