//
//  OptionViewController.h
//  MyKeePass
//
//  Created by Qiang Yu on 3/24/10.
//  Copyright 2010 Qiang Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TKLabelTextFieldCell.h"
#import "FileManagerOperation.h"
#import "ActivityView.h"

@interface OptionViewController : UITableViewController<FileManagerOperationDelegate> {
	TKLabelTextFieldCell * _password1;
	TKLabelTextFieldCell * _password2;
	
	FileManagerOperation * _op;
	ActivityView * _av;	
	NSString * _oldPassword;
}

@property(nonatomic, strong) TKLabelTextFieldCell * _password1;
@property(nonatomic, strong) TKLabelTextFieldCell * _password2;

@property(nonatomic, strong) FileManagerOperation * _op;
@property(nonatomic, strong) ActivityView * _av;

- (IBAction)cancelClicked:(id)sender;
- (IBAction)okClicked:(id)sender;

@end
