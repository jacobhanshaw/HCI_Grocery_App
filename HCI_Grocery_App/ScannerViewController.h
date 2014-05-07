//
//  ViewController.h
//  iOS7_BarcodeScanner
//
//  Created by Jake Widmer on 11/16/13.
//  Copyright (c) 2013 Jake Widmer. All rights reserved.
//

@protocol ScannerViewControllerDelegate <NSObject>

-(BOOL) scannedItem:(NSString *) item;

@end

@interface ScannerViewController : UIViewController

- (ScannerViewController *) initWithDelegate:(id<ScannerViewControllerDelegate>) delegate;

@end
