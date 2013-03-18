//
//  EntryViewController.h
//  MyKeePass
//
//  Created by Qiang Yu on 3/7/10.
//  Copyright 2010 Qiang Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Kdb.h>
#import "PasswordDisclosureView.h"

@interface EntryViewController : UITableViewController <UIActionSheetDelegate,ModalDelegate>
{
	id<KdbEntry> _entry;
	BOOL _passwordShown;
	
	PasswordDisclosureView * _passwordDisclosureView;
    __unsafe_unretained id<ModalDelegate> _delegate;
}

@property(nonatomic, readonly) id<KdbEntry> _entry;
@property(nonatomic, strong) PasswordDisclosureView * _passwordDisclosureView;

- (id)initWithEntry:(id<KdbEntry>)entry delegate:(id <ModalDelegate>)delegate;
- (IBAction)editClicked:(id)sender;
- (IBAction)viewPasswordClicked:(id)sender;

@end
