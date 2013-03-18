//
//  EditGroupViewController.h
//  MyKeePass
//
//  Created by Qiang Yu on 3/15/10.
//  Copyright 2010 Qiang Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <KdbLib.h>

@interface EditNodeNameViewController : UITableViewController
{
	id<KdbGroup> _group;
	id<KdbEntry> _entry;
    __unsafe_unretained id<ModalDelegate> _delegate;
}

@property(nonatomic, strong) id<KdbGroup> _group;
@property(nonatomic, strong) id<KdbEntry> _entry;

- (IBAction)cancelClicked:(id)sender;
- (IBAction)doneClicked:(id)sender;
+ (id)controllerWithDelegate:(id <ModalDelegate>)delegate;

@end
