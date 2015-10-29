# FMHierarchicalSelector
###### _Hierarchical Selector Component based on UIPickerView &amp; UICollectionView_

After all the excitement of globular metaballs, pressure sensitive drawing and weighing plums using 3D Touch, it’s back to a slightly more pedestrian subject: a “hierarchical selector” composite component using a `UIPickerView` to navigate categories and a `UICollectionView` to select items from those categories.

This component will be part of version 3 of Nodality, my node based image processing application. In Nodality, Core Image filter categories (such as _blur_) will be the categories and the filters themselves (such as _Gaussian Blur_) will be the items.

In the demo application, I’m using countries as categories and a handful of their cities as the items. When the taps on a city item, a map centers onto that selected city. I’ve also added a ‘back’ button - just to prove that the new component can be set programatically. 

The component has the natty title of `FMHierarchicalSelector` and is available at my GitHub repository here.

## Implementing `FMHierarchicalSelector`

To use `FMHierarchicalSelector` in your own project, you’ll need a delegate that implements `FMHierarchicalSelectorDelegate`. This protocol contains three methods:

#### Categories

```
func categoriesForHierarchicalSelector(hierarchicalSelector: FMHierarchicalSelector) -> [FMHierarchicalSelectorCategory]
```
Returns an array of categories (`FMHierarchicalSelectorCategory`). Categories are simply strings, so my implementation for the demo simply looks like:

```
let categories: [FMHierarchicalSelectorCategory] = [
    "Australia",
    "Canada",
    "Switzerland",
    "Italy",
    "Japan"].sort()

```

#### Items

```
func itemsForHierarchicalSelector(hierarchicalSelector: FMHierarchicalSelector) -> [FMHierarchicalSelectorItem]
```
Returns a flat array of all of the items. Your item type must implement `FMHierarchicalSelectorItem` which includes getters and setters for the items `name` and `category`. Obviously, you can add whatever additional data you need, so for my project I’ve created an `Item` struct that also has a `coordinate` property of type `CLLocationCoordinate2D`. 

My `itemsForHierarchicalSelector()` looks a little like this:

```
let items: [FMHierarchicalSelectorItem] = [
    Item(category: "Australia", name: "Canberra", coordinate: CLLocationCoordinate2D(latitude: -35.3075, longitude: 149.1244)),
    Item(category: "Australia", name: "Sydney", coordinate: CLLocationCoordinate2D(latitude: -33.8650, longitude: 151.2094)),
```

#### Responding to Change

```
func itemSelected(hierarchicalSelector: FMHierarchicalSelector, item: FMHierarchicalSelectorItem)

```

The final function in `FMHierarchicalSelectorDelegate` is invoked on the delegate when the user selects a new item (city in the case of the demo).

The `item` argument is of type `FMHierarchicalSelectorItem`, so in my implementation, I attempt to cast it as an `Item` and if successful, I can extract the geographic coordinates of the selected city and update my map accordingly:

```
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

```
## In Conclusion

Although the visual design of `FMHierarchicalSelector` is very much geared to the next version of Nodality, its designed to work with any kind of data and is, therefore, a pretty versatile component to enable users to navigate through large datasets. 

`FMHierarchicalSelector` is available at my GitHub repository here.
