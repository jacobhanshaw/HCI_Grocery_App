//
//  LogInViewController.m
//  HCI_Grocery_App
//
//  Created by Jacob Hanshaw on 5/7/14.
//  Copyright (c) 2014 Jacob Hanshaw. All rights reserved.
//

#import "LogInViewController.h"

#import "AppModel.h"

@interface LogInViewController ()

@end

@implementation LogInViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)submitButtonPressed:(id)sender
{
    [AppModel sharedAppModel].loggedIn = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
