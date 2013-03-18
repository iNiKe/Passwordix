//
//  NewLocalFileViewController.m
//  MyKeePass
//
//  Created by Qiang Yu on 3/4/10.
//  Copyright 2010 Qiang Yu. All rights reserved.
//

#import "NewLocalFileViewController.h"
#import "TKLabelTextFieldCell.h"
#import "FileManager.h"

#define ROW_FILENAME	0
#define ROW_PASSWORD_1	1
#define ROW_PASSWORD_2	2
#define ROW_VERSION		3

@interface NewLocalFileViewController (PrivateMethods)
- (void)newKDB3File:(NSString *)filename withPassword:(NSString *)password keyFile:(NSString *)keyFile;
@end

@implementation NewLocalFileViewController

+ (id)controllerWithDelegate:(id<ModalDelegate>)delegate
{
    return [[NewLocalFileViewController alloc] initWithDelegate:delegate];
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
	
	self.navigationItem.title = NSLocalizedString(@"New File", @"New File");
	
	UIBarButtonItem * cancel = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Cancel", @"Cancel") 
															   style:UIBarButtonItemStylePlain target:self action:@selector(cancelClicked:)];
	self.navigationItem.leftBarButtonItem = cancel;
	
	UIBarButtonItem * done = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Done", @"Done") 
															 style:UIBarButtonItemStyleDone target:self action:@selector(doneClicked:)];
	self.navigationItem.rightBarButtonItem = done;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	TKLabelTextFieldCell * cell = (TKLabelTextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	[cell.field becomeFirstResponder];						
}

- (void)didReceiveMemoryWarning {
   [super didReceiveMemoryWarning];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"NLFVCell";

    TKLabelTextFieldCell *cell = (TKLabelTextFieldCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[TKLabelTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

	cell.field.secureTextEntry = NO;
	cell.field.clearsOnBeginEditing = NO;
	cell.field.text=@"";
	
    switch(indexPath.row){
		case ROW_FILENAME:{
			cell.field.placeholder = NSLocalizedString(@"File Name", @"File Name");
			break;
		}
		case ROW_PASSWORD_1:{
			cell.field.placeholder = NSLocalizedString(@"Password", @"Password");
			cell.field.secureTextEntry = YES;
			cell.field.clearsOnBeginEditing = YES;
			break;
		}
		case ROW_PASSWORD_2:{
			cell.field.placeholder = NSLocalizedString(@"Retype Password", @"Retype Password");
			cell.field.secureTextEntry = YES;
			cell.field.clearsOnBeginEditing = YES;
			break;
		}
		//case ROW_VERSION:{
		//	cell.label.text = NSLocalizedString(@"Kdb Version", @"Kdb Version");
		//	break;
		//}
	}
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;	
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 3;
}

- (IBAction)cancelClicked:(id)sender
{
    [_delegate dismissModalViewCancel:self];
}

- (IBAction)doneClicked:(id)sender
{
    [Flurry logEvent:@"KDB.New.LocalFile.OK"];
	TKLabelTextFieldCell *filename  = (TKLabelTextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	TKLabelTextFieldCell *password1 = (TKLabelTextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
	TKLabelTextFieldCell *password2 = (TKLabelTextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];	
	
	
	if ([password1.field.text length] == 0)
    {
		UIAlertView * alert = [[UIAlertView alloc]initWithTitle:nil 
														message:NSLocalizedString(@"Password cannot be empty", @"Password cannot be empty") delegate:nil
											  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
											  otherButtonTitles:nil];	
		[alert show];
		return;
	}
	
	if (![password1.field.text isEqualToString:password2.field.text])
    {
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil
														message:NSLocalizedString(@"Passwords don't match", @"Passwords don't match") delegate:nil
											  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
											  otherButtonTitles:nil];	
		[alert show];
	}
    else
    {
		NSString *name = [FileManager getFullFileName:[filename.field.text stringByAppendingPathExtension:@"kdb"]];
		if ([[NSFileManager defaultManager] fileExistsAtPath:name])
        {
			UIAlertView * alert = [[UIAlertView alloc]initWithTitle:nil 
															message:NSLocalizedString(@"File already exsits. Do you want to overwrite it?", @"File already exists, overwrite?") delegate:self
												  cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
												  otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];	
			[alert show];
		}
        else
			[self newKDB3File:[filename.field.text stringByAppendingPathExtension:@"kdb"] withPassword:password1.field.text keyFile:nil];
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
    {
		TKLabelTextFieldCell * filename  = (TKLabelTextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
		TKLabelTextFieldCell * password1 = (TKLabelTextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
		[self newKDB3File:[filename.field.text stringByAppendingPathExtension:@"kdb"] withPassword:password1.field.text keyFile:nil];
	}
}

- (void)newKDB3File:(NSString *)filename withPassword:(NSString *)password keyFile:(NSString *)keyFile
{
	@try
    {
		[FileManager newKdb3File:filename withPassword:password keyFile:keyFile];
	}
    @catch(NSException * exception)
    {
		UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil
													 	 message:NSLocalizedString(@"Error creating new file", @"Error creating new file") delegate:nil
											   cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
											   otherButtonTitles:nil];
		[alert show];
		return;
	}
    [_delegate dismissModalViewOK:self];
}

@end
