//
//  AppModel.h
//  FireWall
//
//  Created by Jacob Hanshaw on 9/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@class GroceryItem;

@interface AppModel : NSObject

+ (AppModel *)sharedAppModel;

@property (nonatomic) BOOL loggedIn;
@property (nonatomic) BOOL idVerified;

- (GroceryItem *) itemForBarcode:(NSString *) barcode;
- (NSDictionary *) shoppingCart;
- (void) addObjectToCart:(GroceryItem *) item;
- (void) removeObjectFromCart:(GroceryItem *) item;

@end
