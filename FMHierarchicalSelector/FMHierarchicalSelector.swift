//
//  FMHierarchicalSelector.swift
//  FMHierarchicalSelector
//
//  Created by Simon Gladman on 29/10/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//


import UIKit

class FMHierarchicalSelector: UIView
{
    weak var delegate: FMHierarchicalSelectorDelegate?
    
    let dividerLine = CAShapeLayer()
    
    let categoryPicker = UIPickerView()
    let itemsCollectionView: UICollectionView
    
    override init(frame: CGRect)
    {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 150, height: 40)
        
        itemsCollectionView = UICollectionView(frame: CGRectZero,
            collectionViewLayout: layout)
        
        super.init(frame: frame)
        
        itemsCollectionView.delegate = self
        itemsCollectionView.dataSource = self
        itemsCollectionView.registerClass(ItemRenderer.self,
            forCellWithReuseIdentifier: "ItemRenderer")
        
        itemsCollectionView.backgroundColor = UIColor.lightGrayColor()
        
        dividerLine.strokeColor = UIColor.darkGrayColor().CGColor
        dividerLine.lineWidth = 1
        itemsCollectionView.layer.addSublayer(dividerLine)
        
        backgroundColor = UIColor.lightGrayColor()
        
        categoryPicker.dataSource = self
        categoryPicker.delegate = self
        categoryPicker.backgroundColor = UIColor.lightGrayColor()
        
        addSubview(categoryPicker)
        addSubview(itemsCollectionView)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    var categories: [FMHierarchicalSelectorCategory]
        {
            return delegate?.categoriesForHierarchicalSelector(self) ?? [FMHierarchicalSelectorCategory]()
    }
    
    var items: [FMHierarchicalSelectorItem]
        {
            return delegate?.itemsForHierarchicalSelector(self) ?? [FMHierarchicalSelectorItem]()
    }
    
    private var selectedCategory: FMHierarchicalSelectorCategory!
        {
        didSet
        {
            guard oldValue != selectedCategory else
            {
                return
            }
            
            if let categoryIndex  = categories.indexOf(selectedCategory)
            {
                categoryPicker.selectRow(categoryIndex, inComponent: 0, animated: true)
            }
            
            itemsForCategory = items.filter{ $0.category == selectedCategory }
        }
    }
    
    var selectedItem: FMHierarchicalSelectorItem?
        {
        didSet
        {
            guard let selectedItem = selectedItem where categories.contains(selectedItem.category) else
            {
                return
            }
            
            selectedCategory = selectedItem.category
            
            delegate?.itemSelected(self, item: selectedItem)
            
            categoryPicker.reloadAllComponents()
            
            if oldValue?.category == selectedItem.category
            {
                itemsCollectionView.reloadData()
            }
        }
    }
    
    var itemsForCategory: [FMHierarchicalSelectorItem]!
        {
        didSet
        {
            guard oldValue != nil else
            {
                itemsCollectionView.reloadData()
                
                return
            }
            
            UIView.animateWithDuration(0.2, animations: {self.itemsCollectionView.alpha = 0})
                {
                    _ in
                    self.itemsCollectionView.reloadData()
                    UIView.animateWithDuration(0.2)
                        {
                            self.itemsCollectionView.alpha = 1
                    }
            }
        }
    }
    
    override func didMoveToWindow()
    {
        if selectedItem == nil
        {
            selectedCategory = categories[0]
        }
    }
    
    override func layoutSubviews()
    {
        categoryPicker.frame = CGRect(x: 0,
            y: 0,
            width: (frame.width * 0.333),
            height: frame.height).insetBy(dx: 5, dy: 0)
        
        itemsCollectionView.frame = CGRect(x: frame.width * 0.333,
            y: 0,
            width: frame.width * 0.666,
            height: frame.height)
        
        dividerLine.path = CGPathCreateWithRect(
            CGRect(x: 0,
                y: 5,
                width: 0.5,
                height: frame.height - 10), nil)
        
        categoryPicker.setNeedsLayout()
    }
}

// MARK: UICollectionViewDelegate

extension FMHierarchicalSelector: UICollectionViewDelegate
{
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        selectedItem = itemsForCategory[indexPath.item]
        
        return true
    }
}

// MARK: UICollectionViewDataSource

extension FMHierarchicalSelector: UICollectionViewDataSource
{
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return itemsForCategory.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ItemRenderer",
            forIndexPath: indexPath) as! ItemRenderer
        
        cell.item = itemsForCategory[indexPath.item]
        
        if let selectedItem = selectedItem
        {
            cell.selected = itemsForCategory[indexPath.item] == selectedItem
            
            if cell.selected
            {
                collectionView.selectItemAtIndexPath(indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.None)
            }
        }
        
        return cell
    }
}

// MARK: UIPickerViewDataSource

extension FMHierarchicalSelector: UIPickerViewDataSource
{
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return categories.count
    }
}

// MARK: UIPickerViewDelegate

extension FMHierarchicalSelector: UIPickerViewDelegate
{
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        let title: String
        
        if let selectedItemCategory = selectedItem?.category where selectedItemCategory == categories[row]
        {
            title = categories[row] + " •"
        }
        else
        {
            title = categories[row]
        }
        
        return title
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        selectedCategory = categories[row]
    }
}

// MARK: Data types

/// Type alias for a top level category which will appear in the left hand picker view
typealias FMHierarchicalSelectorCategory = String

/// A selectable item which will appear in the right hand side collection view
protocol FMHierarchicalSelectorItem
{
    var name: String {get set}
    var category: FMHierarchicalSelectorCategory {get set}
}

func == (lhs: FMHierarchicalSelectorItem, rhs: FMHierarchicalSelectorItem) -> Bool
{
    return lhs.name == rhs.name && lhs.category == rhs.category
}

// MARK: Delegate protocol

protocol FMHierarchicalSelectorDelegate: class
{
    func categoriesForHierarchicalSelector(hierarchicalSelector: FMHierarchicalSelector) -> [FMHierarchicalSelectorCategory]
    func itemsForHierarchicalSelector(hierarchicalSelector: FMHierarchicalSelector) -> [FMHierarchicalSelectorItem]
    
    func itemSelected(hierarchicalSelector: FMHierarchicalSelector, item: FMHierarchicalSelectorItem)
}

// MARK: Item Renderer

class ItemRenderer: UICollectionViewCell
{
    private let label = UILabel()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        addSubview(label)
        
        layer.borderColor = UIColor.darkGrayColor().CGColor
        layer.borderWidth = 1
        
        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor.blackColor()
        label.textAlignment = NSTextAlignment.Center
        label.frame = CGRect(origin: CGPointZero, size: frame.size).insetBy(dx: 5, dy: 5)
    }
    
    override var selected: Bool
    {
        didSet
        {
            if oldValue != selected
            {
                UIView.animateWithDuration(0.2)
                {
                    self.backgroundColor = self.selected ? UIColor.yellowColor() : nil
                }
            }
        }
    }
    
    var item: FMHierarchicalSelectorItem?
        {
        didSet
        {
            label.text = item?.name
        }
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}
