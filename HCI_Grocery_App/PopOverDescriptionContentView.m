//
//  PopOverDescriptionContentView.m
//  ByteMe
//
//  Created by Jacob Hanshaw on 9/2/13.
//  Copyright (c) 2013 Jacob Hanshaw. All rights reserved.
//

#import "PopOverDescriptionContentView.h"

#import "AppModel.h"
#import "Game.h"
#import "GateLevel.h"
#import "DynamicTextViewCell.h"
#import "TruthTableView.h"
#import "BlackBoxCell.h"

#define X_INSET 10
#define Y_INSET 40

#define TITLE_CELL_IDENTIFIER @"TitleCell"
#define DESCRIPTION_CELL_IDENTIFIER @"DescriptCell"
#define TRUTH_TABLE_CELL_IDENTIFIER @"TruthTableCell"
#define GATE_DESCRIPTION_CELL_IDENTIFIER @"GateDescriptionCell"

#define TITLE_CELL_HEIGHT 44
#define TRUTH_TABLE_ROW_HEIGHT 20
#define TRUTH_TABLE_COL_WIDTH  50

typedef enum {
    TitleSection,
    DescriptionSection,
    TruthTableSection,
    GateDescriptionSection,
    NumSections
} SectionLabel;

@interface PopOverDescriptionContentView() <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *descriptionTable;
    DynamicTextViewCell *descriptionCellPrototype;
    
    TruthTableView *truthTable;
}

@end

@implementation PopOverDescriptionContentView

- (id)init
{
    self = [super init];
    if (self)
    {
        descriptionTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 1, 1) style:UITableViewStylePlain];
        descriptionTable.dataSource = self;
        descriptionTable.delegate = self;
        descriptionTable.bounces = NO;
        [self addSubview:descriptionTable];
        
        truthTable = [[TruthTableView alloc] initWithFrame:CGRectMake(0, 0, 100, 100) inputs:((GateLevel *)[AppModel sharedAppModel].currentGame.currentLevel).initialInputs goalOutputs:((GateLevel *)[AppModel sharedAppModel].currentGame.currentLevel).goalResults andLabels:nil];
        [truthTable setUpWithFrame: CGRectMake(0, 0, truthTable.numCols * TRUTH_TABLE_COL_WIDTH, truthTable.numRows * TRUTH_TABLE_ROW_HEIGHT)];
        
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(didRotate:) name: UIDeviceOrientationDidChangeNotification object: nil];
    }
    return self;
}

- (void) setUpWithAvailableFrame:(CGRect) frame
{
    CGRect realFrame = CGRectInset(frame, X_INSET, Y_INSET);
    self.frame = realFrame;
    descriptionTable.frame = CGRectMake(0, 0, realFrame.size.width, realFrame.size.height);
}

- (void) dealloc
{
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return NumSections;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case TitleSection:
            return 1;
        case DescriptionSection:
            return 1;
        case TruthTableSection:
            return 1;
        case GateDescriptionSection:
            return [[((GateLevel *)[AppModel sharedAppModel].currentGame.currentLevel).boxes allKeys] count];
        default:
            return 1;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == DescriptionSection)
        return @"Goal";
    else if(section == TruthTableSection)
        return @"Truth Table";
    else if (section == GateDescriptionSection)
        return @"Components";
    
    return nil;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case TitleSection:
            return TITLE_CELL_HEIGHT;
        case DescriptionSection:
        {
            if(!descriptionCellPrototype)
            {
                descriptionCellPrototype = [[DynamicTextViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: GATE_DESCRIPTION_CELL_IDENTIFIER];
                descriptionCellPrototype.textView.text = @"HA"; //Goofiness, but otherwise font property of textview is nil
            }

            CGSize newLabelFrameSize = [((GateLevel *)[AppModel sharedAppModel].currentGame.currentLevel).goalMessage sizeWithFont:descriptionCellPrototype.textView.font
                                          constrainedToSize:CGSizeMake(descriptionCellPrototype.textView.frame.size.width, MAXFLOAT)
                                              lineBreakMode:NSLineBreakByWordWrapping];
            return newLabelFrameSize.height + 2 * DYNAMIC_TEXTVIEW_CELL_Y_MARGIN;
        }
        case TruthTableSection:
            return TRUTH_TABLE_ROW_HEIGHT * truthTable.numRows;
        case GateDescriptionSection:
            return BLACKBOX_CELL_HEIGHT;
        default:
            return 44;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case TitleSection:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TITLE_CELL_IDENTIFIER];
            if(!cell)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TITLE_CELL_IDENTIFIER];
                cell.textLabel.textAlignment = UITextAlignmentCenter;
                cell.textLabel.text = [NSString stringWithFormat:@"Level %d: %@", ((GateLevel *)[AppModel sharedAppModel].currentGame.currentLevel).levelNumber, ((GateLevel *)[AppModel sharedAppModel].currentGame.currentLevel).title];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
            return cell;
        }
        case DescriptionSection:
        {
            DynamicTextViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DESCRIPTION_CELL_IDENTIFIER];
            if(!cell)
            {
                cell = [[DynamicTextViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DESCRIPTION_CELL_IDENTIFIER];
                cell.textView.text = ((GateLevel *)[AppModel sharedAppModel].currentGame.currentLevel).goalMessage;
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
            
            return cell;
        }
        case TruthTableSection:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TRUTH_TABLE_CELL_IDENTIFIER];
            if(!cell)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TRUTH_TABLE_CELL_IDENTIFIER];
                UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
                scrollView.contentSize = truthTable.frame.size;
                scrollView.autoresizingMask |= UIViewAutoresizingFlexibleWidth;
                scrollView.autoresizingMask |= UIViewAutoresizingFlexibleHeight;
                scrollView.bounces = NO;
                [scrollView addSubview:truthTable];
                [cell addSubview:scrollView];
                
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
            
            return cell;
        }
        case GateDescriptionSection:
        {
            BlackBoxCell *cell = [tableView dequeueReusableCellWithIdentifier:GATE_DESCRIPTION_CELL_IDENTIFIER];
            if (cell == nil)
            {
                cell = [[BlackBoxCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:GATE_DESCRIPTION_CELL_IDENTIFIER];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
            
            return cell;
        }
        default:
            return nil;
    }
    
    return  nil;
}

-(void) tableView:(UITableView *) tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == GateDescriptionSection)
    {
        NSArray *boxTypes = [((GateLevel *)[AppModel sharedAppModel].currentGame.currentLevel) sortedTypes];
        NSDictionary *boxes = ((GateLevel *)[AppModel sharedAppModel].currentGame.currentLevel).boxes;
        
        BlackBox *currentBox = [[boxes objectForKey:[boxTypes objectAtIndex:indexPath.row]] objectAtIndex:0];
        
        [((BlackBoxCell *)cell) updateWithBox:currentBox andImageOnRightSide:(indexPath.row % 2 == 1)];
    }
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark

- (void)didRotate:(NSNotification *)notification
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    //Ignoring specific orientations
    if (orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown || orientation == UIDeviceOrientationUnknown)
        return;

    [descriptionTable reloadData];
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
