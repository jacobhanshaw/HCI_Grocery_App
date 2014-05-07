//
//  RootViewController.m
//  FireWall
//
//  Created by Jacob Hanshaw on 9/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"

#import "AppModel.h"
#import "GroceryItem.h"

#import "PopOverView.h"
#import "PopOverDescriptionContentView.h"

#import "LogInViewController.h"
#import "ScannerViewController.h"

#define ROW_HEIGHT 80;
#define ROW_ID @"GroceryItem"

//#define WALL_SETTINGS_BUTTON_WIDTH 150
//#define WALL_SETTINGS_BUTTON_HEIGHT 20

@interface RootViewController() <UITableViewDataSource, UITableViewDelegate, ScannerViewControllerDelegate, PopOverViewDelegate>

@end

@implementation RootViewController
{
    UITableView *_groceriesList;
    ScannerViewController *_scannerVC;
}

+ (id) sharedRootViewController
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id) init
{
    if((self = [super init]))
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:@"CartChanged" object:nil];
    
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(![AppModel sharedAppModel].loggedIn)
        [self presentViewController:[[LogInViewController alloc] init] animated:YES completion:nil];
}

-(BOOL) scannedItem:(NSString *) item
{
    GroceryItem *scannedItem = [[AppModel sharedAppModel] itemForBarcode:item];
    
    if(![scannedItem.name isEqualToString:@"CHECKOUT"])
    {
        [self presentPopOverForGroceryItem:scannedItem];
        return YES;
    }
    
    return NO;
}

- (void)presentPopOverForGroceryItem:(GroceryItem *) item
{
    PopOverDescriptionContentView *itemContentView;
    
    PopOverView *popOver = [[PopOverView alloc] initWithFrame:self.view.frame andContentView:itemContentView];
    popOver.delegate = self;
    popOver.alpha = 0.0f;
    [self.view addSubview:popOver];
    
    [UIView animateWithDuration:POP_OVER_ANIMATION_DURATION delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{ popOver.alpha = 1.0f; }
                     completion:nil];
}

- (void) popOverDismissed
{
    
}

#pragma mark TableView Methods

- (void) refresh
{
    [_groceriesList reloadData];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[AppModel sharedAppModel].shoppingCart allKeys] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ROW_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ROW_ID];
    
	if (cell == nil)
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:ROW_ID];
	
    cell.textLabel.text = [[[AppModel sharedAppModel].shoppingCart allKeys] objectAtIndex:indexPath.row];
    
    GroceryItem *currentItem = [[AppModel sharedAppModel].shoppingCart objectForKey:[[[AppModel sharedAppModel].shoppingCart allKeys] objectAtIndex:indexPath.row]];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%f x %f", currentItem.count, currentItem.price];
    
	return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	// Return NO if you do not want the specified item to be editable.
	return YES;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
	if (editingStyle == UITableViewCellEditingStyleDelete) {
        GroceryItem *currentItem = [[AppModel sharedAppModel].shoppingCart objectForKey:[[[AppModel sharedAppModel].shoppingCart allKeys] objectAtIndex:indexPath.row]];
        [[AppModel sharedAppModel] removeObjectFromCart:currentItem];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
	}
	if (editingStyle == UITableViewCellEditingStyleInsert) {
		// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
	}
}



@end