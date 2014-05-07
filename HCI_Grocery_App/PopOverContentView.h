//
//  PopOverContentView.h
//  ByteMe
//
//  Created by Jacob Hanshaw on 7/17/13.
//
//

@protocol PopOverContentViewDelegate <NSObject>
@required
- (void) dismiss;
@end

@interface PopOverContentView : UIView

@property(nonatomic, weak) id<PopOverContentViewDelegate> dismissDelegate;

- (void) setUpWithAvailableFrame:(CGRect) frame;

@end