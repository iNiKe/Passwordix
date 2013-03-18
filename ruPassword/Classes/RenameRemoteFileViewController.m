//
//  RenameRemoteFileViewController.m
//  MyKeePass
//
//  Created by Qiang Yu on 3/21/10.
//  Copyright 2010 Qiang Yu. All rights reserved.
//

#import "RenameRemoteFileViewController.h"
#import "TKLabelTextFieldCell.h"

#define ROW_NAME 0
#define ROW_URL	 1

@implementation RenameRemoteFileViewController
@synthesize _name;
@synthesize _url;

+ (id)controllerWithDelegate:(id<ModalDelegate>)delegate
{
    return [[RenameRemoteFileViewController alloc] initWithDelegate:delegate];
}

- (id)initWithDelegate:(id<ModalDelegate>)delegate
{
    if ((self = [self initWithStyle:UITableViewStyleGrouped]))
    {
        _delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.navigationItem.title = NSLocalizedString(@"Rename File", @"Rename File");
	
	UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                              style:UIBarButtonItemStylePlain target:self action:@selector(cancelClicked:)];
	self.navigationItem.leftBarButtonItem = cancel;
	
	UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done")
                                                            style:UIBarButtonItemStyleDone target:self action:@selector(doneClicked:)];
	self.navigationItem.rightBarButtonItem = done;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	TKLabelTextFieldCell *cell = (TKLabelTextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	[cell.field becomeFirstResponder];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NLFVCell";
	
    TKLabelTextFieldCell *cell = (TKLabelTextFieldCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[TKLabelTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
	
	cell.field.clearsOnBeginEditing = NO;
	
    switch (indexPath.row)
    {
		case ROW_NAME:
        {
			cell.field.placeholder= _name;
			cell.field.text = _name;
			cell.field.keyboardType = UIKeyboardTypeDefault;
			cell.field.autocapitalizationType = UITextAutocapitalizationTypeSentences;			
			break;
		}
		case ROW_URL:
        {
			cell.field.placeholder = _url;
			cell.field.text = _url;
			cell.field.keyboardType = UIKeyboardTypeURL;
			cell.field.autocapitalizationType = UITextAutocapitalizationTypeNone;
			break;
		}
	}
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;	
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 2;
}

- (IBAction)cancelClicked:(id)sender
{
    [_delegate dismissModalViewCancel:self];
}

- (IBAction)doneClicked:(id)sender
{
    [Flurry logEvent:@"KDB.Rename.RemoteFile.OK"];
	TKLabelTextFieldCell *cell = (TKLabelTextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	NSString *name = [cell.field.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if (name == nil || [name length] == 0)
    {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil 
														message:NSLocalizedString(@"Name cannot be empty", @"Name cannot be empty") delegate:nil 
											  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
											  otherButtonTitles:nil];	
		[alert show];
	}
    else
    {
		TKLabelTextFieldCell *cell = (TKLabelTextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
		NSString * url = [cell.field.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		if (url == nil || [url length] == 0)
        {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
															 message:NSLocalizedString(@"URL cannot be empty", @"URL cannot be empty") delegate:nil 
												   cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
												   otherButtonTitles:nil];	
			[alert show];
		}
        else
        {
			if (![name isEqualToString:_name] && [MyAppDelegate.fileManager getURLForRemoteFile:name])
            {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil 
                                                                message:NSLocalizedString(@"A same name already exists", @"Name already exisits") delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                      otherButtonTitles:nil];
				[alert show];
			}
            else
            {
				[MyAppDelegate.fileManager deleteRemoteFile:_name];
				[MyAppDelegate.fileManager addRemoteFile:name Url:url];
                [_delegate dismissModalViewOK:self];
			}
		}
	}
}

@end

