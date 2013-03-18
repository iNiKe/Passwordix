//
//  GroupViewController.h
//  MyKeePass
//
//  Created by Qiang Yu on 3/6/10.
//  Copyright 2010 Qiang Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Kdb.h>
#import "GroupedSectionHeader.h"
#import "FileManagerOperation.h"
#import "ActivityView.h"

@interface GroupViewController : UITableViewController <UIAlertViewDelegate, FileManagerOperationDelegate, ModalDelegate>
{
	id<KdbGroup> _group;
	GroupedSectionHeader *_groupSectionHeader, *_entrySectionHeader;
	
	BOOL _isRoot;
	NSIndexPath *_rowToDelete;
	
	NSArray *_subGroups, *_entries;
	
	ActivityView *_av;
	FileManagerOperation *_op;
    __unsafe_unretained id<ModalDelegate> _delegate;
}

@property(nonatomic, readonly) id<KdbGroup> _group;
@property(nonatomic, strong) GroupedSectionHeader *_groupSectionHeader, *_entrySectionHeader;
@property(nonatomic, assign) BOOL _isRoot;
@property(nonatomic, strong) NSIndexPath * _rowToDelete;
@property(nonatomic, strong) NSArray *_subGroups, *_entries;

@property(nonatomic, strong) ActivityView *_av;
@property(nonatomic, strong) FileManagerOperation *_op;

- (id)initWithGroup:(id<KdbGroup>)group delegate:(id <ModalDelegate>)delegate;
- (IBAction)addEntry:(id)sender;
- (IBAction)addGroup:(id)sender;

@end
