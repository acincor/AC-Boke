//
//  PicturePickerController.swift
//  SelectPhotos
//
//  Created by mhc team on 2022/11/26.
//

import UIKit

private let PicturePickerCellID = "Cell"
private let picturePickerMaxCount = 8
class PicturePickerController: UICollectionViewController {
    private var selectedIndex = 0
    lazy var pictures = [UIImage]()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(PicturePickerCell.self, forCellWithReuseIdentifier: PicturePickerCellID)
        // Do any additional setup after loading the view.
    }
    #if os(visionOS)
    override var preferredContainerBackgroundStyle: UIContainerBackgroundStyle {
        return .glass
    }
    #endif
    init() {
        super.init(collectionViewLayout: PicturePickerLayout())
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
extension PicturePickerController: PicturePickerCellDelegate {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pictures.count + (pictures.count == picturePickerMaxCount ? 0 : 1)
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PicturePickerCellID, for: indexPath) as! PicturePickerCell
        // Configure the cell
        cell.image = (indexPath.item < pictures.count) ? pictures[indexPath.item] : nil
        cell.pictureDelegate = self
        return cell
    }
    @objc func picturePickerDidAdd(cell: PicturePickerCell) {
        if !UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
        }
        let picker = UIImagePickerController()
        selectedIndex = collectionView.indexPath(for: cell)?.item ?? 0
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    @objc func picturePickerDidRemove(cell: PicturePickerCell) {
        let indexPath = collectionView.indexPath(for: cell)
        if indexPath!.item >= pictures.count {
            return
        }
        pictures.remove(at: indexPath!.item)
        collectionView.reloadData()
    }
}
extension PicturePickerController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        dismiss(animated: true,completion: nil)
        if selectedIndex >= pictures.count {
            pictures.append(image)
        } else {
            pictures[selectedIndex] = image
        }
        collectionView.reloadData()
    }
}
private class PicturePickerLayout:UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        let count: CGFloat = 4
        let margin = UIScreen.main.scale * 4
        let w = (collectionView!.bounds.width - (count + 1) * margin) / count
        itemSize = CGSize(width: w, height: w)
        sectionInset = UIEdgeInsets(top: margin, left: margin, bottom: 0, right: margin)
        minimumLineSpacing = margin
        minimumInteritemSpacing = margin
    }
}
