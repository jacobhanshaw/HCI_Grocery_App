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
    NSUserDefaults *_defaults;
    
    NSDictionary *_possibleItems;
    NSMutableDictionary *_shoppingCart;
}

@end

@implementation AppModel

@synthesize loggedIn = _loggedIn;

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
        apple.imageName = @"apple.jpg";
        apple.description = @"Healthy fruit";
        apple.price = 0.59f;
        
        GroceryItem *appleCoupon = [[GroceryItem alloc] init];
        appleCoupon.name = @"Apple - Buy 6, get 2 free";
        appleCoupon.imageName = @"appleCoupon.jpg";
        appleCoupon.description = @"Special Deal for Loyal Copps Customers!";
        appleCoupon.price = 0.59f;
        appleCoupon.count = -2.0f;
        
        apple.coupon = appleCoupon;
        
        GroceryItem *bread = [[GroceryItem alloc] init];
        apple.name = @"Loaf of Bread";
        apple.imageName = @"bread.jpg";
        apple.description = @"Healthy fruit";
        apple.price = 2.78f;
        
        GroceryItem *vodka = [[GroceryItem alloc] init];
        apple.name = @"Smirnoff Vodka 1.75L";
        apple.imageName = @"smirnoff.jpg";
        apple.description = @"Healthy fruit";
        apple.price = 17.99f;
        
        GroceryItem *checkout = [[GroceryItem alloc] init];
        apple.name = @"CHECKOUT";
        apple.imageName = @"error.jpg";
        apple.description = @"SHOULD NOT APPEAR";
        apple.price = -1.0f;
        
        _possibleItems = [NSMutableDictionary dictionaryWithObjectsAndKeys:apple, @"01234567895", appleCoupon, @"01267834595", bread, @"56789501234", vodka, @"01235678954", checkout, @"67012358954", nil];
        
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
