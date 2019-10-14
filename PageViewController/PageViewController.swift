//
//  ACBPageViewController.swift
//  AsiaCreditBankSwift
//
//  Created by Kazhenbayeva Gulnaz on 11/24/17.
//  Copyright © 2017 Kazhenbayeva Gulnaz. All rights reserved.
//

import UIKit
import SnapKit

class PageViewController: UIPageViewController {
    
    fileprivate var headerView: UICollectionView!
    fileprivate var dividerView: UIView!
    fileprivate var activeColor = AppColor.tabTint.uiColor
    fileprivate var inActiveColor = AppColor.tabUnselected.uiColor
    
    fileprivate var pages: [UIViewController] = []
    fileprivate var titleLabels: [UILabel] = []
    
    fileprivate var size: CGFloat = 50
    
    fileprivate var leftConstraint: Constraint!
    fileprivate var currentPage = 0
    
    fileprivate var page: Int {
        set {
            if pages.count >= newValue {
                if newValue < currentPage {
                    setViewControllers([pages[newValue]], direction: .reverse, animated: true, completion: nil)
                } else {
                    setViewControllers([pages[newValue]], direction: .forward, animated: true, completion: nil)
                }
                currentPage = newValue
            }
        }
        get {
            return currentPage
        }
    }
    
    init(pages: [UIViewController]) {
        self.pages = pages
        for vc in pages {
            
            let label = UILabel()
            if let titleText = vc.title {
                label.text = titleText
            }
            titleLabels.append(label)
        }
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        edgesForExtendedLayout = []
        view.backgroundColor = .gray
        
        setupHeaderView()
        setupDividerView()
        configPageView()
    }
    
    
    deinit {
        print("ACBPageViewController deinit")
    }
    
}


// MARK: - configUI
extension PageViewController {
    
    fileprivate func setupHeaderView() {
        
        if pages.count > 0 {
            size = (view.frame.width - CGFloat((pages.count - 1) * 12)) / CGFloat(pages.count)
        }
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = .zero
        layout.itemSize = CGSize(width: size, height: 60)
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        
        headerView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        headerView.backgroundColor = AppColor.background.uiColor
        headerView.showsHorizontalScrollIndicator = false
        headerView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        headerView.dataSource = self
        headerView.delegate = self
        view.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.equalTo(view)
            make.height.equalTo(60)
            make.left.equalTo(view)
            make.right.equalTo(view)
        }
        
    }
    
    fileprivate func setupDividerView() {
        
        dividerView = UIView()
        dividerView.backgroundColor = activeColor
        view.addSubview(dividerView)
        dividerView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(-2)
            self.leftConstraint = make.left.equalTo(headerView).constraint
            make.width.equalTo(size)
            make.height.equalTo(2)
        }
    }
    
    fileprivate func configPageView() {
        
        if let firstPage = pages.first {
            setViewControllers([firstPage], direction: .forward, animated: true, completion: nil)
        }
        
//        dataSource = self
//        delegate = self
    }
    
    
}


// MARK: - Methods
extension PageViewController {
    
    fileprivate func handlePageChange(page: Int) {
        
        let indexPath = IndexPath.init(row: page, section: 0)
        
        if let cell = headerView.cellForItem(at: indexPath) {
            
            headerView.reloadData()
            
            let offset = cell.frame.origin.x
            UIView.animate(withDuration: 0.3) {
                self.leftConstraint.update(offset: offset)
                self.view.layoutSubviews()
            }
        }
    }
}


// MARK: - CollectionViewDataSource, CollectionViewDelegate

extension PageViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        return pages.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath)-> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let titleLabel = titleLabels[indexPath.row]
        titleLabel.textColor = indexPath.row == currentPage ? activeColor : inActiveColor
        titleLabel.textAlignment = .center
        titleLabel.font = AppFont.bold()
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byWordWrapping
        
        cell.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { m in
            m.edges.equalToSuperview()
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.page = indexPath.row
        handlePageChange(page: indexPath.row)
    }
}


// MARK: UIPageViewControllerDataSource

extension PageViewController: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {

        if let viewControllerIndex = self.pages.index(of: viewController) {
            if viewControllerIndex > 0 {
                // wrap to last page in array
                return self.pages[viewControllerIndex - 1]
            }
        }
        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {

        if let viewControllerIndex = self.pages.index(of: viewController) {
            if viewControllerIndex < self.pages.count - 1 {
                // go to next page in array
                return self.pages[viewControllerIndex + 1]
            }
        }
        return nil
    }
}


// MARK: - UIPageViewControllerDelegate

extension PageViewController: UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {

        if let pendingViewController = pendingViewControllers.first {
            if let viewControllerIndex = self.pages.index(of: pendingViewController) {
                handlePageChange(page: viewControllerIndex)
            }
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let index = (self.pages.index(of: (pageViewController.viewControllers?.first)!))!
        self.page = index
        handlePageChange(page: index)
    }
}


