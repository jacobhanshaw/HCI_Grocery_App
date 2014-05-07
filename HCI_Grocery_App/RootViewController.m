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

#define TEXT_COLOR [UIColor blackColor]

#define ROW_HEIGHT 40;
#define ROW_ID @"GroceryItem"

#define STATUS_BAR_HEIGHT 20.0f

#define TOTAL_SECTION_HEIGHT 20.0f

#define SCAN_BUTTON_WIDTH 200.0f
#define SCAN_BUTTON_HEIGHT 100.0f

//#define WALL_SETTINGS_BUTTON_WIDTH 150
//#define WALL_SETTINGS_BUTTON_HEIGHT 20

@interface RootViewController() <UITableViewDataSource, UITableViewDelegate, ScannerViewControllerDelegate, PopOverViewDelegate>

@end

@implementation RootViewController
{
    UITableView *_groceriesList;
    UILabel *_totalLabel;
    UILabel *_totalValueLabel;
    ScannerViewController *_scannerVC;
    
    UIButton *_scanButton;
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
    
    _groceriesList = [[UITableView alloc] initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height/2.0f - TOTAL_SECTION_HEIGHT/2.0f - STATUS_BAR_HEIGHT/2.0f) style:UITableViewStylePlain];
    _groceriesList.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin);
    _groceriesList.dataSource = self;
    _groceriesList.delegate = self;
    
    [self.view addSubview:_groceriesList];
    
    _totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _groceriesList.frame.size.height + STATUS_BAR_HEIGHT, self.view.frame.size.width/2.0f, TOTAL_SECTION_HEIGHT)];
    _totalLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin);
    [_totalLabel setText:@" Total"];
    [_totalLabel setTextColor:TEXT_COLOR];
    
    [self.view addSubview:_totalLabel];
    
    _totalValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0f, _groceriesList.frame.size.height + STATUS_BAR_HEIGHT, self.view.frame.size.width/2.0f, TOTAL_SECTION_HEIGHT)];
    _totalValueLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin);
    [_totalValueLabel setTextAlignment:NSTextAlignmentRight];
    [_totalValueLabel setText:@"$0.00 "];
    [_totalValueLabel setTextColor:TEXT_COLOR];
    
    [self.view addSubview:_totalValueLabel];
    
    /* _scanButton = [UIButton buttonWithType:UIButtonTypeCustom];
     _scanButton.frame = CGRectMake((self.view.frame.size.width - SCAN_BUTTON_WIDTH)/2.0f, self.view.frame.size.height - SCAN_BUTTON_HEIGHT, SCAN_BUTTON_WIDTH, SCAN_BUTTON_HEIGHT);
     _scanButton.titleLabel.font = [UIFont systemFontOfSize:36.0f];
     [_scanButton setTitle:@"Scan" forState:UIControlStateNormal];
     [_scanButton setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
     [_scanButton addTarget:self action:@selector(scan) forControlEvents:UIControlEventTouchUpInside];
     
     [self.view addSubview:_scanButton]; */
    
    _scannerVC = [[ScannerViewController alloc] initWithDelegate:self];
    
    [self addChildViewController:_scannerVC];
    _scannerVC.view.frame = CGRectMake(0, 180, self.view.frame.size.width, self.view.frame.size.height/2.0f - TOTAL_SECTION_HEIGHT/2.0f - STATUS_BAR_HEIGHT/2.0f);
    _scannerVC.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [self.view addSubview:_scannerVC.view];
    [_scannerVC didMoveToParentViewController:self];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(![AppModel sharedAppModel].loggedIn)
        [self presentViewController:[[LogInViewController alloc] init] animated:YES completion:nil];
}

-(void) scan
{
    [self presentViewController:[[ScannerViewController alloc] initWithDelegate:self] animated:YES completion:nil];
}

-(BOOL) scannedItem:(NSString *) item
{
    GroceryItem *scannedItem = [[AppModel sharedAppModel] itemForBarcode:item];
    
    if([scannedItem.name isEqualToString:@"Smirnoff Vodka 1.75L"] && ![AppModel sharedAppModel].idVerified)
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ID Required" message:@"Please scan your ID before adding item." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
        }];
        return YES;
    }
    
    if([scannedItem.name isEqualToString:@"ID"])
    {
        [AppModel sharedAppModel].idVerified = YES;
        [_scannerVC disableQRCodes];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ID Scanned" message:@"Thank you for scanning your ID. You may now add your previous item." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
        }];
        return YES;
    }
    
    if(![scannedItem.name isEqualToString:@"CHECKOUT"])
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
            [self presentPopOverForGroceryItem:scannedItem];
        }];
        
        return YES;
    }
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Complete Checkout" message:@"The weight of the cart is accurate. Woud you like to complete checkout?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [alert show];
    }];
    
    return NO;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0){
        //Code for Done button
        // TODO: Create a finished view
    }
    if(buttonIndex == 1){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Checkout Complete" message:@"You have completed checkout. You may now exit the store." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
}


- (void)presentPopOverForGroceryItem:(GroceryItem *) item
{
    PopOverDescriptionContentView *itemContentView = [[PopOverDescriptionContentView alloc] initWithGroceryItem:item];
    
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
    float total = 0.0f;
    for(GroceryItem *item in [[AppModel sharedAppModel].shoppingCart allValues])
    {
        total += item.count * item.price;
        if(item.isCoupon && [[AppModel sharedAppModel].shoppingCart objectForKey:item.requiredItem.name] == nil)
        {
            [[AppModel sharedAppModel] removeObjectFromCart:item];
            return;
        }
    }
    
    [_totalValueLabel setText:[NSString stringWithFormat: @"$%.02f ", total]];
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
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ROW_ID];
	
    cell.textLabel.text = [[[AppModel sharedAppModel].shoppingCart allKeys] objectAtIndex:indexPath.row];
    
    GroceryItem *currentItem = [[AppModel sharedAppModel].shoppingCart objectForKey:[[[AppModel sharedAppModel].shoppingCart allKeys] objectAtIndex:indexPath.row]];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d x %.02f", (int)currentItem.count, currentItem.price];
    
	return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GroceryItem *currentItem = [[AppModel sharedAppModel].shoppingCart objectForKey:[[[AppModel sharedAppModel].shoppingCart allKeys] objectAtIndex:indexPath.row]];
    
    [self presentPopOverForGroceryItem:currentItem];
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	// Return NO if you do not want the specified item to be editable.
	return YES;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
	if (editingStyle == UITableViewCellEditingStyleDelete) {
        GroceryItem *currentItem = [[AppModel sharedAppModel].shoppingCart objectForKey:[[[AppModel sharedAppModel].shoppingCart allKeys] objectAtIndex:indexPath.row]];
        [[AppModel sharedAppModel] removeObjectFromCart:currentItem];
        //	[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
	}
	if (editingStyle == UITableViewCellEditingStyleInsert) {
		// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
	}
}



@end