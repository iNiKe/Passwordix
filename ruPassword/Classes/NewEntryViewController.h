//
//  NewEntryTableViewController.h
//  MyKeePass
//
//  Created by Qiang Yu on 3/12/10.
//  Copyright 2010 Qiang Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <KdbLib.h>
#import "TKLabelTextFieldCell.h"
#import "TKTextViewCell.h"

@interface NewEntryViewController : UITableViewController
{
	id<KdbGroup> _parent;

	TKLabelTextFieldCell *_entryname, * _username, *_password1, *_password2, *_url;
	
	TKTextViewCell *_comment;
    __unsafe_unretained id<ModalDelegate> _delegate;
}

@property(nonatomic, retain) id<KdbGroup> _parent;

@property(nonatomic, strong) TKLabelTextFieldCell *_entryname, *_username, *_password1, *_password2, *_url;
@property(nonatomic, retain) TKTextViewCell *_comment;

- (IBAction)cancelClicked:(id)sender;
- (IBAction)doneClicked:(id)sender;
+ (id)controllerWithDelegate:(id <ModalDelegate>)delegate;

@end
