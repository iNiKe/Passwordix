//
//  OptionViewController.m
//  MyKeePass
//
//  Created by Qiang Yu on 3/24/10.
//  Copyright 2010 Qiang Yu. All rights reserved.
//

#import "OptionViewController.h"
#import "TKLabelTextFieldCell.h"

@implementation OptionViewController
@synthesize _password1;
@synthesize _password2;
@synthesize _op;
@synthesize _av;

- (id)init
{
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:UITableViewStyleGrouped]))
    {
		_password1 = [[TKLabelTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
		_password2 = [[TKLabelTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
		
		_password1.field.secureTextEntry = YES;
		_password1.field.clearsOnBeginEditing = YES;
		_password1.field.text = @"";
		_password1.field.placeholder = NSLocalizedString(@"New Master Password", @"New Master Password");
		_password1.selectionStyle = UITableViewCellSelectionStyleNone;		

		_password2.field.secureTextEntry = YES;
		_password2.field.clearsOnBeginEditing = YES;
		_password2.field.text = @"";
		_password2.field.placeholder = NSLocalizedString(@"Retype Master Password", @"Retype Master Password");	
		_password2.selectionStyle = UITableViewCellSelectionStyleNone;			
		
		if (!MyAppDelegate.fileManager.editable)
        {
			_password1.field.placeholder = _password2.field.placeholder = NSLocalizedString(@"File is readonly", @"File is readonly");
			_password1.field.enabled = _password2.field.enabled = NO;
		}
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([indexPath row] == 0)
    {
		return _password1;
	}
    else
    {
		return _password2;
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
	UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,100)]; 
	UIButton * ok = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	ok.frame = CGRectMake(11,16,143,35); 
	[ok setTitle:NSLocalizedString(@"OK", @"OK") forState:UIControlStateNormal];
	UIButton * cancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	cancel.frame = CGRectMake(165, 16, 143, 35);
	[cancel setTitle:NSLocalizedString(@"Cancel", @"Cancel") forState:UIControlStateNormal];
	[container addSubview:ok];
	[container addSubview:cancel];
	[cancel addTarget:self action:@selector(cancelClicked:) forControlEvents:UIControlEventTouchUpInside];
	[ok addTarget:self action:@selector(okClicked:) forControlEvents:UIControlEventTouchUpInside];
	ok.enabled = cancel.enabled = MyAppDelegate.fileManager.editable;
	return container;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	return 50;
}

- (IBAction)cancelClicked:(id)sender
{
	_password1.field.text = _password2.field.text = @"";
	[_password1.field resignFirstResponder];
	[_password2.field resignFirstResponder];
}

- (IBAction)okClicked:(id)sender
{
	if ([_password1.field.text length] == 0)
    {
		UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil 
														 message:NSLocalizedString(@"Password cannot be empty", @"Password cannot be empty") delegate:nil
											   cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
											   otherButtonTitles:nil];	
		[alert show];
		return;
	}
	
	if (![_password1.field.text isEqualToString:_password2.field.text])
    {
		UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil 
														message:NSLocalizedString(@"Passwords don't match", @"Passwords don't match") delegate:nil
											   cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
											   otherButtonTitles:nil];	
		[alert show];
	}
    else
    {
		if(!_op) _op = [[FileManagerOperation alloc] initWithDelegate:self];
		if(!_av) _av = [[ActivityView alloc] initWithFrame:CGRectMake(0,0,320,480)];	 
		
		_oldPassword = MyAppDelegate.fileManager.password;
		MyAppDelegate.fileManager.password = _password1.field.text;
		MyAppDelegate.fileManager.dirty = YES;

		[self.view addSubview:_av];
		[_op performSelectorInBackground:@selector(save) withObject:nil];
		
		[_password1.field resignFirstResponder];
		[_password2.field resignFirstResponder];
	}
}

- (void)fileOperationSuccess
{
	[_av removeFromSuperview];	
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil 
										 			 message:NSLocalizedString(@"Password changed successfully", @"Password changed successfully") delegate:nil
										   cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
										   otherButtonTitles:nil];	
	[alert show];
}

- (void)fileOperationFailureWithException:(NSException *)exception
{
	[_av removeFromSuperview];
	MyAppDelegate.fileManager.password = _oldPassword;			
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil
													 message:NSLocalizedString(@"Error Saving File", @"Error Saving File") delegate:nil 
										   cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
										   otherButtonTitles:nil];	
	[alert show];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

@end

