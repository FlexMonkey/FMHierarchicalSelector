//
//  ViewController.swift
//  FMHierarchicalSelector
//
//  Created by Simon Gladman on 29/10/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//


import UIKit
import MapKit

class ViewController: UIViewController
{
    let categories: [FMHierarchicalSelectorCategory] = [
        "Australia",
        "Canada",
        "Switzerland",
        "Italy",
        "Japan"].sort()
    
    let items: [FMHierarchicalSelectorItem] = [
        Item(category: "Australia", name: "Canberra", coordinate: CLLocationCoordinate2D(latitude: -35.3075, longitude: 149.1244)),
        Item(category: "Australia", name: "Sydney", coordinate: CLLocationCoordinate2D(latitude: -33.8650, longitude: 151.2094)),
        Item(category: "Australia", name: "Melbourne", coordinate: CLLocationCoordinate2D(latitude: -37.8136, longitude: 144.9631)),
        Item(category: "Australia", name: "Brisbane", coordinate: CLLocationCoordinate2D(latitude: -27.4667, longitude: 153.0333)),
        Item(category: "Australia", name: "Perth", coordinate: CLLocationCoordinate2D(latitude: -31.9522, longitude: 115.8589)),
        Item(category: "Australia", name: "Adelaide", coordinate: CLLocationCoordinate2D(latitude: -34.9290, longitude: 138.6010)),
        Item(category: "Australia", name: "Gold Coast", coordinate: CLLocationCoordinate2D(latitude: -28.0167, longitude: 153.4000)),
        Item(category: "Australia", name: "Newcastle", coordinate: CLLocationCoordinate2D(latitude: -32.9167, longitude: 151.7500)),
        
        Item(category: "Canada", name: "Ottawa", coordinate: CLLocationCoordinate2D(latitude: 45.4214, longitude: -75.6919)),
        Item(category: "Canada", name: "Toronto", coordinate: CLLocationCoordinate2D(latitude: 43.7000, longitude: -79.4000)),
        Item(category: "Canada", name: "Montreal", coordinate: CLLocationCoordinate2D(latitude: 45.5017, longitude: -73.5673)),
        Item(category: "Canada", name: "Vancouver", coordinate: CLLocationCoordinate2D(latitude: 49.2827, longitude: -123.1207)),
        Item(category: "Canada", name: "Calgary", coordinate: CLLocationCoordinate2D(latitude: 51.0486, longitude: -114.0708)),
        
        Item(category: "Switzerland", name: "Bern", coordinate: CLLocationCoordinate2D(latitude: 46.9500, longitude: 7.4500)),
        Item(category: "Switzerland", name: "Zurich", coordinate: CLLocationCoordinate2D(latitude: 47.3667, longitude: 8.5500)),
        Item(category: "Switzerland", name: "Geneva", coordinate: CLLocationCoordinate2D(latitude: 46.2000, longitude: 6.1500)),
        Item(category: "Switzerland", name: "Basel", coordinate: CLLocationCoordinate2D(latitude: 47.5667, longitude: 7.6000)),
        Item(category: "Switzerland", name: "Lausanne", coordinate: CLLocationCoordinate2D(latitude: 46.5198, longitude: 6.6335)),
        
        Item(category: "Italy", name: "Rome", coordinate: CLLocationCoordinate2D(latitude: 41.9000, longitude: 12.500)),
        Item(category: "Italy", name: "Milan", coordinate: CLLocationCoordinate2D(latitude: 45.4667, longitude: 9.1833)),
        Item(category: "Italy", name: "Naples", coordinate: CLLocationCoordinate2D(latitude: 40.8450, longitude: 14.2583)),
        
        Item(category: "Japan", name: "Kyoto", coordinate: CLLocationCoordinate2D(latitude: 35.0117, longitude: 135.7683)),
        Item(category: "Japan", name: "Osaka", coordinate: CLLocationCoordinate2D(latitude: 34.6939, longitude: 135.5022)),
        Item(category: "Japan", name: "Tokyo", coordinate: CLLocationCoordinate2D(latitude: 35.6833, longitude: 139.6833))
        ].sort({ $0.name < $1.name })
    
    
    let filterPicker = FMHierarchicalSelector()
    let mapView = MKMapView()
    let backButton = UIButton()
    
    var history = [Item]()
    {
        didSet
        {
            guard history.count > 1 else
            {
                backButton.hidden = true
                
                return
            }
            
            backButton.setTitle("◀︎ Back to " + history[history.count - 2].name, forState: UIControlState.Normal)
            backButton.hidden = false
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        filterPicker.delegate = self
        
        view.addSubview(filterPicker)
        view.addSubview(mapView)
        view.addSubview(backButton)
        
        backButton.layer.backgroundColor = UIColor(white: 0.5, alpha: 0.5).CGColor
        backButton.hidden = true
        backButton.addTarget(self, action: "backButtonClickHandler", forControlEvents: UIControlEvents.TouchDown)
        
        filterPicker.selectedItem = items[1]
    }
    
    func backButtonClickHandler()
    {
        history.removeLast()
        
        filterPicker.selectedItem = history.removeLast()
    }
    
    override func viewDidLayoutSubviews()
    {
        mapView.frame = CGRect(x: 0,
            y: topLayoutGuide.length,
            width: view.frame.width,
            height: view.frame.height - topLayoutGuide.length - 200).insetBy(dx: 10, dy: 0)
        
        filterPicker.frame = CGRect(x: 0,
            y: view.frame.height - 200,
            width: view.frame.width,
            height: 200).insetBy(dx: 10, dy: 10)
        
        backButton.frame = CGRect(x: view.frame.width / 2 - 100,
            y: topLayoutGuide.length + 10,
            width: 200,
            height: backButton.intrinsicContentSize().height)
    }
}

extension ViewController: FMHierarchicalSelectorDelegate
{
    func categoriesForHierarchicalSelector(hierarchicalSelector: FMHierarchicalSelector) -> [FMHierarchicalSelectorCategory]
    {
        return categories
    }
    
    func itemsForHierarchicalSelector(hierarchicalSelector: FMHierarchicalSelector) -> [FMHierarchicalSelectorItem]
    {
        return items
    }
    
    func itemSelected(hierarchicalSelector: FMHierarchicalSelector, item: FMHierarchicalSelectorItem)
    {
        guard let item = item as? Item else
        {
            return
        }
        
        let span = MKCoordinateSpanMake(0.5, 0.5)
        let region = MKCoordinateRegionMake(item.coordinate, span)
        
        mapView.setRegion(region, animated: false)
        
        history.append(item)
    }
}

struct Item: FMHierarchicalSelectorItem
{
    var category: FMHierarchicalSelectorCategory
    var name: String
    
    let coordinate: CLLocationCoordinate2D
    
}
