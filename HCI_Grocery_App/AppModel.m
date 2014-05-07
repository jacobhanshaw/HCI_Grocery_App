//
//  AppModel.m
//  FireWall
//
//  Created by Jacob Hanshaw on 9/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppModel.h"

#import "GroceryItem.h"

@interface AppModel()
{
    BOOL _loggedIn;
    BOOL _idVerified;
    NSUserDefaults *_defaults;
    
    NSDictionary *_possibleItems;
    NSMutableDictionary *_shoppingCart;
}

@end

@implementation AppModel

@synthesize loggedIn = _loggedIn;
@synthesize idVerified = _idVerified;

+ (id)sharedAppModel
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

#pragma mark Init/dealloc
-(id)init {
    self = [super init];
    if (self) {
        _loggedIn = NO;
        
        GroceryItem *apple = [[GroceryItem alloc] init];
        apple.name = @"Apple";
        apple.imageName = @"apple.png";
        apple.description = @"Healthy fruit";
        apple.price = 0.59f;
        
        GroceryItem *bread = [[GroceryItem alloc] init];
        bread.name = @"Sweet Bread";
        bread.imageName = @"bread.png";
        bread.description = @"King's Hawaiian Sweet Bread";
        bread.price = 4.78f;
        
        GroceryItem *breadCoupon = [[GroceryItem alloc] init];
        breadCoupon.isCoupon = YES;
        breadCoupon.name = @"$2.00 Off Sweet Bread";
        breadCoupon.imageName = @"breadCoupon.png";
        breadCoupon.description = @"Special Deal for Loyal Copps Customers!";
        breadCoupon.price = 2.00f;
        breadCoupon.count = -1.0f;
        breadCoupon.requiredItem = bread;
        
        bread.coupon = breadCoupon;
        
        GroceryItem *vodka = [[GroceryItem alloc] init];
        vodka.name = @"Smirnoff Vodka 1.75L";
        vodka.imageName = @"smirnoff.jpg";
        vodka.description = @"Vodka";
        vodka.price = 17.99f;
        
        GroceryItem *idCard = [[GroceryItem alloc] init];
        idCard.name = @"ID";
        idCard.imageName = @"error.jpg";
        idCard.description = @"SHOULD NOT APPEAR";
        idCard.price = -1.0f;
        
        GroceryItem *checkout = [[GroceryItem alloc] init];
        checkout.name = @"CHECKOUT";
        checkout.imageName = @"error.jpg";
        checkout.description = @"SHOULD NOT APPEAR";
        checkout.price = -1.0f;
        
        _possibleItems = [NSMutableDictionary dictionaryWithObjectsAndKeys:apple, @"0036000291452", breadCoupon, @"9788679912077", bread, @"9771234567003", vodka, @"0824150401483", idCard, @"Jacob's ID", checkout, @"0671860013624", nil];
        
        _shoppingCart = [[NSMutableDictionary alloc] initWithCapacity:4];
	}
    return self;
}

- (GroceryItem *) itemForBarcode:(NSString *) barcode
{
    return [_possibleItems objectForKey:barcode];
}

- (NSDictionary *) shoppingCart
{
    return ((NSDictionary *)_shoppingCart);
}

- (void) addObjectToCart:(GroceryItem *) item
{
    [_shoppingCart setObject:item forKey:item.name];
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"CartChanged" object:nil]];
}

- (void) removeObjectFromCart:(GroceryItem *) item
{
    if(item.count > 0)
        item.count = 0;
    
    [_shoppingCart removeObjectForKey:item.name];
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"CartChanged" object:nil]];
}

#pragma mark User Defaults

/*
 in object
 
 - (void)encodeWithCoder:(NSCoder *)encoder {
 //Encode properties, other class variables, etc
 [encoder encodeObject:self.question forKey:@"question"];
 [encoder encodeObject:self.categoryName forKey:@"category"];
 [encoder encodeObject:self.subCategoryName forKey:@"subcategory"];
 }
 
 - (id)initWithCoder:(NSCoder *)decoder {
 if((self = [super init])) {
 //decode properties, other class vars
 self.question = [decoder decodeObjectForKey:@"question"];
 self.categoryName = [decoder decodeObjectForKey:@"category"];
 self.subCategoryName = [decoder decodeObjectForKey:@"subcategory"];
 }
 return self;
 }
 Reading and writing from NSUserDefaults:
 
 - (void)saveCustomObject:(MyObject *)object key:(NSString *)key {
 NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:object];
 NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
 [defaults setObject:myEncodedObject forKey:key];
 [defaults synchronize];
 
 }
 
 - (MyObject *)loadCustomObjectWithKey:(NSString *)key {
 NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
 NSData *encodedObject = [defaults objectForKey:key];
 MyObject *object = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
 return object;
 }

-(void)clearUserDefaults
{
	NSLog(@"Clearing User Defaults");

    [defaults setInteger:playerId       forKey:@"playerId"];
    [defaults setInteger:fallbackGameId forKey:@"gameId"];
    [defaults setInteger:playerMediaId  forKey:@"playerMediaId"];
    [defaults setObject:userName        forKey:@"userName"];
    [defaults setObject:displayName     forKey:@"displayName"];
    [defaults setObject:NULL            forKey:@"notifNotes"];
    [defaults setObject:NULL            forKey:@"cachedImages"];
    
	[defaults synchronize]; */
//}

-(void)loadUserDefaults
{
	NSLog(@"Loading User Defaults");

     /*   self.playerId        = [defaults integerForKey:@"playerId"];
        self.playerMediaId   = [defaults integerForKey:@"playerMediaId"];
        self.userName        = [defaults objectForKey:@"userName"];
        self.displayName     = [defaults objectForKey:@"displayName"];
        self.groupName       = [defaults objectForKey:@"groupName"];
        self.groupGame       = [[defaults objectForKey:@"groupName"] intValue]; */

}

-(void)saveUserDefaults
{
	NSLog(@"Saving User Defaults");
	
	/*[defaults setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"appVerison"];
	[defaults setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBuildNumber"]   forKey:@"buildNum"];
    
    [defaults setInteger:playerId                                       forKey:@"playerId"];
    [defaults setInteger:playerMediaId                                  forKey:@"playerMediaId"];
    [defaults setInteger:fallbackGameId                                 forKey:@"gameId"];
    [defaults setObject:userName                                        forKey:@"userName"];
    [defaults setObject:displayName                                     forKey:@"displayName"];
    [defaults setObject:[InnovNoteModel sharedNoteModel].notifNotes     forKey:@"notifNotes"];
    [defaults setObject:cachedImages                                    forKey:@"cachedImages"];
	[defaults synchronize]; */
}


@end
