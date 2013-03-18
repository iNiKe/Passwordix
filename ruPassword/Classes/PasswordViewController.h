//
//  PasswordViewController.h
//  MyKeePass
//
//  Created by Qiang Yu on 3/8/10.
//  Copyright 2010 Qiang Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TKLabelTextFieldCell.h"
#import "ActivityView.h"
#import "FileManagerOperation.h"
#import "ModalDelegate.h"

@interface PasswordViewController : UITableViewController<FileManagerOperationDelegate, UITextFieldDelegate, ModalDelegate>
{
	NSString *_filename, *_keyFilename;
	
	FileManagerOperation *_op;
	BOOL _isRemote, _isReopen, _isLoading;
	
    ActivityView *_av;
	UIButton *_ok, *_cancel;
	UISwitch *_switch;
	UITableViewCell *_useCache, *_keyFileCell;
	TKLabelTextFieldCell *_password, *_rusername, *_rpassword, *_rdomain;
    __unsafe_unretained id<ModalDelegate> _delegate;
}

@property(nonatomic, strong) NSString * _filename;
@property(nonatomic, assign) BOOL _isRemote;
@property(nonatomic, assign) BOOL _isReopen;
@property(nonatomic, strong) ActivityView * _av;

@property(nonatomic, strong) UIButton * _ok;
@property(nonatomic, strong) UIButton * _cancel;
@property(nonatomic, strong) UISwitch * _switch;

@property(nonatomic, strong) TKLabelTextFieldCell * _password;
@property(nonatomic, strong) UITableViewCell * _useCache, *_keyFileCell;
@property(nonatomic, strong) TKLabelTextFieldCell * _rusername;
@property(nonatomic, strong) TKLabelTextFieldCell * _rpassword;
@property(nonatomic, retain) TKLabelTextFieldCell * _rdomain;

@property(nonatomic, strong) FileManagerOperation * _op;

- (IBAction)cancelClicked:(id)sender;
- (IBAction)okClicked:(id)sender;
+ (id)controllerWithDelegate:(id<ModalDelegate>)delegate fileName:(NSString *)fileName remote:(BOOL)isRemote;

@end
