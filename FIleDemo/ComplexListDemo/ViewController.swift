//
//  ViewController.swift
//  ComplexListDemo
//
//  Created by apple on 2022/5/13.
//

import UIKit


class ViewController: UIViewController {
    var collectionViewPresenter =  DefaultCollectionViewPresenter()
    

    private(set) var collectionV: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configCollectionViewData()
    }
}


//MARK: -
private
extension ViewController {
    func configCollectionViewData() {
           var sections:[CollectionViewSectionPresenter]  = []
           //section 0
           do {
               let sectionModel = CollectionViewSectionPresenter()
               sectionModel.header = RedHeaderPresenter()
               sectionModel.footer = BlueFooterPresenter()
               for _ in 0..<2 {
                   let cellP = TwoLabelCellPresenter()
                   cellP.txt0 = "三国演义 （罗贯中著长篇小说）"
                   cellP.txt1 = "《三国演义》（全名为《三国志通俗演义》，又称《三国志演义》）是元末明初小说家罗贯中根据陈寿《三国志》和裴松之注解以及民间三国故事传说经过艺术加工创作而成的长篇章回体历史演义小说，与《西游记》《水浒传》《红楼梦》并称为中国古典四大名著。该作品成书后有嘉靖壬午本等多个版本传于世，到了明末清初，毛宗岗对《三国演义》整顿回目、修正文辞、改换诗文，该版本也成为诸多版本中水平最高、流传最广的版本。"
                   sectionModel.items.append(cellP)
               }
               sections.append(sectionModel)
           }
           //section 1
           do {
               let sectionModel = CollectionViewSectionPresenter()
               for _ in 0..<10 {
                   let cellP = GridCellPresenter()
                   sectionModel.items.append(cellP)
               }
               sections.append(sectionModel)
           }
           //Section 2
           do {
               let sectionPresenter = TwoItemGridSection()
               sectionPresenter.sectionInsets = .init(top: 30, left: 10, bottom: 30, right: 10)
               sectionPresenter.minimumLineSpacing = 10.0
               sectionPresenter.minimumInteritemSpacing = 10.0
               for _ in 0..<10 {
                   let cellP = GridCellPresenter()
                   sectionPresenter.items.append(cellP)
               }
               sections.append(sectionPresenter)
           }
           self.collectionViewPresenter.sections = sections
           collectionV.reloadData()
    }
    func setupUI() {
        let flowLayout = UICollectionViewFlowLayout()
        collectionV = UICollectionView.init(frame: .zero, collectionViewLayout: flowLayout)
        collectionV.dataSource = collectionViewPresenter
        collectionV.delegate = collectionViewPresenter
        view.addSubview(collectionV)
        collectionV.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionV.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionV.rightAnchor.constraint(equalTo: view.rightAnchor),
            collectionV.topAnchor.constraint(equalTo: view.topAnchor),
            collectionV.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        collectionV.register(cellPresenterType: TwoLabelCellPresenter.self)
        collectionV.register(footerPresenterType: BlueFooterPresenter.self)
        collectionV.register(headerPresenterType: RedHeaderPresenter.self)
        collectionV.register(cellPresenterType: GridCellPresenter.self)
    }
}
