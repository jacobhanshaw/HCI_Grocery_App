//
//  GroceryItem.h
//  HCI_Grocery_App
//
//  Created by Jacob Hanshaw on 5/7/14.
//  Copyright (c) 2014 Jacob Hanshaw. All rights reserved.
//

@interface GroceryItem : NSObject

@property(nonatomic) BOOL     isCoupon;
@property(nonatomic) NSString *name;
@property(nonatomic) float    price;
@property(nonatomic) NSString *imageName;
@property(nonatomic) NSString *description;
@property(nonatomic) int    count;
@property(nonatomic, weak) GroceryItem *coupon;
@property(nonatomic, weak) GroceryItem *requiredItem;

@end
