//
//  RenameFileViewController.m
//  MyKeePass
//
//  Created by Qiang Yu on 3/21/10.
//  Copyright 2010 Qiang Yu. All rights reserved.
//

#import "RenameFileViewController.h"
#import "TKLabelTextFieldCell.h"
#import "FileManager.h"

@implementation RenameFileViewController
@synthesize _filename;

+ (id)controllerWithDelegate:(id<ModalDelegate>)delegate
{
    return [[RenameFileViewController alloc] initWithDelegate:delegate];
}

- (id)initWithDelegate:(id<ModalDelegate>)delegate
{
    if ((self = [self initWithStyle:UITableViewStyleGrouped]))
    {
        _delegate = delegate;
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:YES];
	TKLabelTextFieldCell *cell = (TKLabelTextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	[cell.field becomeFirstResponder];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.navigationItem.title = NSLocalizedString(@"Rename File", @"Rename File");
	
	UIBarButtonItem *cancel = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Cancel", @"Cancel") 
															   style:UIBarButtonItemStylePlain target:self action:@selector(cancelClicked:)];
	self.navigationItem.leftBarButtonItem = cancel;
	
	UIBarButtonItem *done = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"OK", @"OK")
															 style:UIBarButtonItemStyleDone target:self action:@selector(doneClicked:)];
	self.navigationItem.rightBarButtonItem = done;
}


- (IBAction)cancelClicked:(id)sender
{
    [_delegate dismissModalViewCancel:self];
}

- (IBAction)doneClicked:(id)sender
{
    [Flurry logEvent:@"KDB.Rename.LocalFile.OK"];
	NSString *filename = ((TKLabelTextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]).field.text;
	
	if ([filename length] != 0)
    {
		if ([_filename hasSuffix:@".kdb"] && ![filename hasSuffix:@".kdb"])
        {
			filename = [filename stringByAppendingPathExtension:@"kdb"];
		}
        else if ([_filename hasSuffix:@".kdbx"] && ![filename hasSuffix:@".kdbx"])
        {
			filename = [filename stringByAppendingPathExtension:@"kdbx"];
		}
				
		NSString *name = [FileManager getFullFileName:filename];
		if (!([filename isEqualToString:_filename]) && [[NSFileManager defaultManager] fileExistsAtPath:name])
        {
			UIAlertView * alert = [[UIAlertView alloc]initWithTitle:nil 
															message:NSLocalizedString(@"File already exsits", @"File already exists") delegate:self
												  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
												  otherButtonTitles:nil];	
			[alert show];
			return;
		}
        else
        {
			[[NSFileManager defaultManager] moveItemAtPath:[FileManager getFullFileName:_filename] toPath:name error:nil];
		}
	}
	[_delegate dismissModalViewOK:self];
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
    return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    TKLabelTextFieldCell *cell = (TKLabelTextFieldCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[TKLabelTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
	cell.field.placeholder = _filename;
	cell.field.text = _filename;
	
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return NSLocalizedString(@"New name of the file:", @"New name");
}

@end

