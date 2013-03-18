//
//  EditGroupViewController.m
//  MyKeePass
//
//  Created by Qiang Yu on 3/15/10.
//  Copyright 2010 Qiang Yu. All rights reserved.
//

#import "EditNodeNameViewController.h"
#import "TKLabelTextFieldCell.h"
#import "FileManager.h"
//#import "MyKeePassAppDelegate.h"

@implementation EditNodeNameViewController
@synthesize _group;
@synthesize _entry;

+ (id)controllerWithDelegate:(id <ModalDelegate>)delegate
{
    return [[EditNodeNameViewController alloc] initWithDelegate:delegate];
}

- (id)initWithDelegate:(id <ModalDelegate>)delegate
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
	UIBarButtonItem * cancel = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Cancel", @"Cancel") 
															   style:UIBarButtonItemStylePlain target:self action:@selector(cancelClicked:)];
	
	self.navigationItem.title = NSLocalizedString(@"Change Name", @"Change Name");
	
	self.navigationItem.leftBarButtonItem = cancel;
	
	UIBarButtonItem * done = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Done", @"Done") 
															 style:UIBarButtonItemStyleDone target:self action:@selector(doneClicked:)];
	self.navigationItem.rightBarButtonItem = done;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	TKLabelTextFieldCell *cell = (TKLabelTextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	[cell.field becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
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

// Customize the appearance of table view cells
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
    
	TKLabelTextFieldCell *cell = (TKLabelTextFieldCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[TKLabelTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
    
	cell.field.secureTextEntry = NO;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.field.text = _group ? [_group getGroupName] : [_entry getEntryName];
	
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return _group ? NSLocalizedString(@"Group Name", @"Group Name") : NSLocalizedString(@"Entry Name", @"Entry Name");
}

- (IBAction)cancelClicked:(id)sender
{
    [_delegate dismissModalViewCancel:self];
}

- (IBAction)doneClicked:(id)sender
{
    [Flurry logEvent:@"KDB.Edit.Node.Name.OK"];
	FileManager * fm = MyAppDelegate.fileManager;
	TKLabelTextFieldCell * cell = (TKLabelTextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	if (_group)
    {
		[_group setGroupName:cell.field.text];
		NSDate * now = [NSDate date];
		[_group setLastMod:now];
		[_group setLastAccess:now];		
	}
    else
    {
		[_entry setEntryName:cell.field.text];
		NSDate * now = [NSDate date];
		[_entry setLastMod:now];
		[_entry setLastAccess:now];	
		[[NSNotificationCenter defaultCenter] postNotificationName:@"EntryUpdated" object:nil];		
	}
	fm.dirty = YES;
    [_delegate dismissModalViewOK:self];
}

@end

