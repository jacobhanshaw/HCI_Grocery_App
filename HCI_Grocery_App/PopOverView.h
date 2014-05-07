//
//  PopOverView.h
//  ByteMe
//
//  Created by JacobJamesHanshaw on 6/19/13.
//
//

#define NAV_BAR_HEIGHT 44
#define POP_OVER_ANIMATION_DURATION 0.1f

@class PopOverContentView;

@protocol PopOverViewDelegate <NSObject>
@required
- (void) popOverDismissed;
@end

@interface PopOverView : UIView

@property(nonatomic, weak) id<PopOverViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame andContentView: (PopOverContentView *) inputContentView;
- (void)adjustContentFrame:(CGRect)frame;

@end