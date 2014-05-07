//
//  PopOverView.m
//  ByteMe 
//
//  Created by JacobJamesHanshaw on 6/19/13.
//
//

#import "PopOverView.h"
#import <QuartzCore/QuartzCore.h>

#import "PopOverContentView.h"

#define CORNER_RADIUS  9.0
#define BUTTON_HEIGHT  40
#define BUTTON_WIDTH   40

@interface PopOverView() <PopOverContentViewDelegate>
{
    PopOverContentView *contentView;
    UIButton *exitButton;
}

@end

@implementation PopOverView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame andContentView: (PopOverContentView *) inputContentView
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [[UIColor alloc] initWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
        contentView = inputContentView;
        contentView.clipsToBounds = YES;
        contentView.layer.masksToBounds = YES;
        contentView.layer.cornerRadius  = CORNER_RADIUS;
        [contentView setUpWithAvailableFrame:frame];
        contentView.center = self.center;
        contentView.dismissDelegate = self;
        [self addSubview:contentView];
        
        exitButton = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                          0,
                                                                          BUTTON_WIDTH,
                                                                          BUTTON_HEIGHT)];
        exitButton.center = CGPointMake(self.frame.origin.x + contentView.frame.origin.x + contentView.frame.size.width,
                                        self.frame.origin.y + contentView.frame.origin.y);
        exitButton.imageView.contentMode = UIViewContentModeCenter;
        [exitButton setImage:[UIImage imageNamed:@"298-circlex-white.png"] forState:UIControlStateNormal];
        [exitButton setImage:[UIImage imageNamed:@"298-circlex-white.png"] forState:UIControlStateHighlighted];
        [exitButton addTarget:self action:@selector(exitButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview: exitButton];
    }
    return self;
}

- (void) adjustContentFrame:(CGRect)frame
{
    [contentView setUpWithAvailableFrame:frame];
    exitButton.center = CGPointMake(self.frame.origin.x + contentView.frame.origin.x + contentView.frame.size.width,
                                    self.frame.origin.y + contentView.frame.origin.y);
}

- (void) exitButtonPressed: (id) sender
{
    if(delegate)
        [delegate popOverDismissed];
    [self dismiss];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    for(UITouch *touch in touches)
    {
        CGPoint point = [touch locationInView:self];
         if(!CGRectContainsPoint(contentView.frame, point))
         {
             if(delegate)
                 [delegate popOverDismissed];
             [self dismiss];
         }
    }
   
}

- (void) dismiss
{
    __weak UIView *weakSelf = self;
    [UIView animateWithDuration:POP_OVER_ANIMATION_DURATION delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{ weakSelf.alpha = 0.0f; }
                     completion:^(BOOL finished) { [weakSelf removeFromSuperview]; }];
}

@end