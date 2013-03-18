//
//  EditNodeViewController.h
//  MyKeePass
//
//  Created by Qiang Yu on 3/15/10.
//  Copyright 2010 Qiang Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <KdbLib.h>
#import "TKLabelTextFieldCell.h"
#import "TKTextViewCell.h"
#import "FileManagerOperation.h"
#import "ActivityView.h"

@interface EditNodeViewController : UITableViewController<FileManagerOperationDelegate>
{
	id<KdbEntry> _entry;
	FileManagerOperation *_op;
	ActivityView *_av;
	
	TKLabelTextFieldCell *_username, *_password1, *_password2, *_url;
	
	TKTextViewCell *_comment;
    __unsafe_unretained id<ModalDelegate> _delegate;
}

@property (nonatomic, strong) id<KdbEntry> _entry;
@property (nonatomic, strong) FileManagerOperation * _op;
@property (nonatomic, strong) ActivityView * _av;

@property (nonatomic, strong) TKLabelTextFieldCell * _username;
@property (nonatomic, strong) TKLabelTextFieldCell * _password1;
@property (nonatomic, strong) TKLabelTextFieldCell * _password2;
@property (nonatomic, strong) TKLabelTextFieldCell * _url;
@property (nonatomic, strong) TKTextViewCell * _comment;

- (IBAction)cancelClicked:(id)sender;
- (IBAction)doneClicked:(id)sender;
+ (id)controllerWithDelegate:(id <ModalDelegate>)delegate;

@end
