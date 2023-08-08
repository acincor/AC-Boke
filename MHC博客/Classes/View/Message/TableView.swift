//
//  TableView.swift
//  MHC博客
//
//  Created by mhc team on 2023/7/27.
//

import Foundation
import UIKit
 
class TableView:UITableView,UITableViewDelegate, UITableViewDataSource
{
    //用于保存所有消息
    var bubbleSection:Array<MessageItem>!
    //数据源，用于与 ViewController 交换数据
    var chatDataSource:ChatDataSource!
     
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
    }
    override init(frame:CGRect,style: Style)
    {
        self.bubbleSection = Array<MessageItem>()
         
        super.init(frame:frame, style:.plain)
         
        self.backgroundColor = UIColor.white
         
        self.separatorStyle = .none
        self.delegate = self
        self.dataSource = self
         
         
    }
     
    override func reloadData()
    {
        //self.showsVerticalScrollIndicator = false
        //self.showsHorizontalScrollIndicator = false
        bubbleSection.removeAll()
        var count = 0
        if ((self.chatDataSource != nil))
        {
            count = self.chatDataSource.rowsForChatTable(tableView: self)
             
            if(count > 0)
            {
                 
                for i in 0 ... count - 1
                {
                     
                    var object =  self.chatDataSource.chatTableView(tableView: self, dataForRow:i)
                    bubbleSection.append(object)
                     
                }
                 
                //按日期排序方法
                bubbleSection.sort(by: {$0.date.timeIntervalSince1970 < $1.date.timeIntervalSince1970})
            }
        }
        super.reloadData()
    }
     
    //第一个方法返回分区数，在本例中，就是1
    func numberOfSectionsInTableView(tableView:UITableView)->Int
    {
        return 1
    }
     
    //返回指定分区的行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (section >= self.bubbleSection.count)
        {
            return 0
        }
         
        return self.bubbleSection.count
    }
         
    //用于确定单元格的高度，如果此方法实现得不对，单元格与单元格之间会错位
    func tableView(_ tableView:UITableView,heightForRowAt indexPath:IndexPath) -> CGFloat
    {
         
        var data =  self.bubbleSection[indexPath.row]
         
        return max(data.insets.top + data.view.frame.size.height + data.insets.bottom, 52)
    }
     
    //返回自定义的 TableViewCell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
           
        var cellId = "MsgCell"
        var data =  self.bubbleSection[indexPath.row]
     
        var cell =  TableViewCell(data:data, reuseIdentifier:cellId)
     
        return cell
    }
}
