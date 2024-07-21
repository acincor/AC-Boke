//
//  ChatDataSourch.swift
//  AC博客
//
//  Created by AC on 2023/7/27.
//

import Foundation
import UIKit
//数据协议
import Foundation
 
/*
  数据提供协议
*/
protocol ChatDataSource
{
    /*返回对话记录中的全部行数*/
    func rowsForChatTable( tableView:TableView) -> Int
    /*返回某一行的内容*/
    func chatTableView(tableView:TableView, dataForRow:Int)-> MessageItem
}
