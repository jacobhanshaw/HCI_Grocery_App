//
//  PopOverDescriptionContentView.m
//  ByteMe
//
//  Created by Jacob Hanshaw on 9/2/13.
//  Copyright (c) 2013 Jacob Hanshaw. All rights reserved.
//

#import "PopOverDescriptionContentView.h"

#import "AppModel.h"
#import "GroceryItem.h"

#define X_INSET 10
#define Y_INSET 40

#define TEXT_COLOR [UIColor blackColor]

#define SPACING 5.0f

#define TITLE_HEIGHT 20.0f
#define TITLE_DESC_SPACING 10.0f

#define IMAGE_SIZE 100.0f
#define IMAGE_DESC_SPACE 10.0f

#define DESC_HEIGHT 50.0f
#define DESC_NEXT_HEIGHT 10.0f

#define COUP_HEIGHT 100.0f
#define COUP_NEXT_HEIGHT 0.0f

#define CHECK_SIZE 50.0f

#define COUNT_WIDTH 50.0f
#define COUNT_HEIGHT 40.0f

#define COUNT_BUTTON_WIDTH 50.0f

#define COUNT_ADD_SPACING 30.0f

#define ADD_HEIGHT 100.0f

@implementation PopOverDescriptionContentView
{
    GroceryItem *_item;
    BOOL couponUsed;
    
    UILabel *_titleLabel;
    UIImageView *_imageView;
    UITextView *_description;
    UIButton *_couponButton;
    UIImageView *_checkmark;
    UILabel *_countLabel;
    UIButton *_lessButton;
    UIButton *_moreButton;
    UIButton *_addButton;
}

- (id)initWithGroceryItem:(GroceryItem *) item
{
    self = [super init];
    if (self)
    {
        _item = item;
        self.opaque = YES;
        self.backgroundColor = [UIColor whiteColor];
    }
    
    return self;
}

- (void) setUpWithAvailableFrame:(CGRect) frame
{
    CGRect realFrame = CGRectInset(frame, X_INSET, Y_INSET);
    self.frame = realFrame;
    
    float height = SPACING;
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(SPACING, height, realFrame.size.width - IMAGE_SIZE - 2 * SPACING, TITLE_HEIGHT)];
    _titleLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin);
    [_titleLabel setText:_item.name];
    [_titleLabel setTextColor:TEXT_COLOR];
    
    [self addSubview:_titleLabel];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(realFrame.size.width - IMAGE_SIZE - SPACING, height, IMAGE_SIZE, IMAGE_SIZE)];
    _imageView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin);
    [_imageView setImage:[UIImage imageNamed:_item.imageName]];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self addSubview:_imageView];
    
    _description = [[UITextView alloc] initWithFrame:CGRectMake(SPACING, TITLE_HEIGHT + TITLE_DESC_SPACING, 100.0f, DESC_HEIGHT)];
    _description.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin);
    [_description setText: _item.description];
    [_description setTextColor:TEXT_COLOR];
    
    [self addSubview:_description];

    height += IMAGE_SIZE + IMAGE_DESC_SPACE;
    
    if(_item.coupon || _item.isCoupon)
    {
        _couponButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _couponButton.frame = CGRectMake(SPACING, height, realFrame.size.width - 2 * SPACING, COUP_HEIGHT);
        _couponButton.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight |  UIViewAutoresizingFlexibleBottomMargin);
        if(_item.isCoupon)
               [_couponButton setBackgroundImage:[UIImage imageNamed:_item.imageName] forState:UIControlStateNormal];
        else
                [_couponButton setBackgroundImage:[UIImage imageNamed:_item.coupon.imageName] forState:UIControlStateNormal];
        [_couponButton addTarget:self action:@selector(couponToggle) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_couponButton];
        
        _checkmark = [[UIImageView alloc] initWithFrame:CGRectMake(_couponButton.frame.size.width - CHECK_SIZE, 0, CHECK_SIZE, CHECK_SIZE)];
        _checkmark.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin);
        [_checkmark setImage:[UIImage imageNamed:@"checkMark.png"]];
        
        [_couponButton addSubview:_checkmark];
        
        couponUsed = [[AppModel sharedAppModel].shoppingCart objectForKey:_item.coupon.name] != nil;
        _checkmark.hidden = !couponUsed;
        
        height += COUP_HEIGHT + COUP_NEXT_HEIGHT;
    }
    
    if(!_item.isCoupon)
    {
        float countSpacing = realFrame.size.width - COUNT_WIDTH - 2.0f* COUNT_BUTTON_WIDTH;
        countSpacing /= 4.0f;
        
        _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(2.0f * countSpacing + COUNT_BUTTON_WIDTH, height, COUNT_WIDTH, COUP_HEIGHT)];
        _countLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin);
        [_countLabel setTextAlignment:NSTextAlignmentCenter];
        [_countLabel setText:[NSString stringWithFormat:@"%d", _item.count]];
        [_countLabel setTextColor:TEXT_COLOR];
        
        [self addSubview:_countLabel];
        
        _lessButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _lessButton.frame = CGRectMake(countSpacing, height, COUNT_BUTTON_WIDTH, COUP_HEIGHT);
        _lessButton.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin);
        [_lessButton setTitle:@"-" forState:UIControlStateNormal];
        [_lessButton addTarget:self action:@selector(countChange:) forControlEvents:UIControlEventTouchUpInside];
        [_lessButton setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
        _lessButton.tag = -1;
        
        [self addSubview:_lessButton];
        
        _moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _moreButton.frame = CGRectMake(_countLabel.frame.origin.x + _countLabel.frame.size.width + countSpacing, height, COUNT_BUTTON_WIDTH, COUP_HEIGHT);
        _moreButton.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin);
        [_moreButton setTitle:@"+" forState:UIControlStateNormal];
        [_moreButton addTarget:self action:@selector(countChange:) forControlEvents:UIControlEventTouchUpInside];
        [_moreButton setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
        _moreButton.tag = 1;
        
        [self addSubview:_moreButton];
        
        height += COUNT_HEIGHT + COUNT_ADD_SPACING;
    }
    
    
    _addButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    _addButton.frame = CGRectMake(SPACING, height, realFrame.size.width - 2 * SPACING, ADD_HEIGHT);
    _addButton.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin);
    [_addButton setImage:[UIImage imageNamed:@"addToCart.png"] forState:UIControlStateNormal];
    [_addButton addTarget:self action:@selector(addItem) forControlEvents:UIControlEventTouchUpInside];
    [_addButton setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    
    [self addSubview:_addButton];
    
}

- (void) couponToggle
{
    couponUsed = !couponUsed;
    
    _checkmark.hidden = !couponUsed;
}

- (void) countChange:(UIButton *) button
{
    _item.count += button.tag;
    [_countLabel setText:[NSString stringWithFormat:@"%d", _item.count]];
}

- (void) addItem
{
    if(_item.isCoupon)
    {
        if(couponUsed && [[AppModel sharedAppModel].shoppingCart objectForKey:_item.requiredItem.name] != nil)
            [[AppModel sharedAppModel] addObjectToCart:_item];
        else
            [[AppModel sharedAppModel] removeObjectFromCart:_item];
    }
    else
    {
        if(_item.count > 0)
            [[AppModel sharedAppModel] addObjectToCart:_item];
        else
            [[AppModel sharedAppModel] removeObjectFromCart:_item];
        
        if(_item.coupon)
        {
            if(couponUsed && _item.count > 0)
                [[AppModel sharedAppModel] addObjectToCart:_item.coupon];
            else
                [[AppModel sharedAppModel] removeObjectFromCart:_item.coupon];
        }
    }
    
    [self.dismissDelegate dismiss];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
