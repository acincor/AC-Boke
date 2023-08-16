//
//  StatusListViewModel.swift
//  MHC微博
//
//  Created by Monkey hammer on 2022/9/11.
//

import UIKit

class StatusListViewModel {
    lazy var statusList = [StatusViewModel]()
    var pulldownCount: Int?
    func loadStatus(isPullup: Bool,finished: @escaping (_ isSuccessed: Bool) -> ()) {
        let since_id = isPullup ? 0 : (statusList.first?.status.id ?? 0)
        let max_id = isPullup ? (statusList.last?.status.id ?? 0) : 0
        StatusDAL.loadStatus(since_id: since_id, max_id: max_id) { (array) -> () in
            guard let array = array else {
                //print("数据格式错误")
                finished(false)
                return
            }
            var dataList = [StatusViewModel]()
            //print(result)
            for n in 0..<array.count {
                //print(array[n])
                //print(Status(dict: array[n]))
                dataList.append(StatusViewModel(status: Status(dict: array[n])))
            }
            //print("bool:",dataList.count > self.statusList.count)
            self.pulldownCount = self.statusList.count == 0 ? dataList.count : (dataList.count > self.statusList.count ? dataList.count - self.statusList.count: nil)
            if max_id > 0 {
                self.statusList += dataList
            } else {
                self.statusList = dataList
            }
            self.cacheSingleImage(dataList: dataList, finished: finished)
        }
    }
    private func cacheSingleImage(dataList: [StatusViewModel],finished: @escaping (_ isSuccessed: Bool) -> ()) {
        let group = DispatchGroup()
        var dataLength = 0
        for vm in dataList {
            if vm.thumbnailUrls?.count != 1 {
                continue
            }
            let url = vm.thumbnailUrls![0]
            //print("要缓存的\(url)")
            group.enter()
            SDWebImageManager.shared.loadImage(with: url,options: [SDWebImageOptions.retryFailed, SDWebImageOptions.refreshCached], progress: nil,completed: { (image,_,_,_,_,_) -> Void in
                if let img = image,let data = img.pngData() {
                    //print(data.count)
                    dataLength += data.count
                }
            })
            group.leave()
        }
        group.notify(queue: DispatchQueue.main) {
            //print("缓存完成\(dataLength / 1024)K")
            finished(true)
        }
    }
}
