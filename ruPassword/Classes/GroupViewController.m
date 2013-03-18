//
//  GroupViewController.m
//  MyKeePass
//
//  Created by Qiang Yu on 3/6/10.
//  Copyright 2010 Qiang Yu. All rights reserved.
//

#import "GroupViewController.h"
#import "EntryViewController.h"
#import "GroupedSectionHeader.h"
#import "NewEntryViewController.h"
#import "NewGroupViewController.h"
#import "EditNodeNameViewController.h"
#import "Sort.h"

#define SECTION_GROUP 0
#define SECTION_ENTRY 1

@interface GroupViewController(PrivateMethod)
- (void)refreshData;
@end


@implementation GroupViewController
@synthesize _group;
@synthesize _groupSectionHeader;
@synthesize _entrySectionHeader;
@synthesize _isRoot;
@synthesize _rowToDelete;
@synthesize _subGroups;
@synthesize _entries;
@synthesize _av;
@synthesize _op;

- (id)initWithGroup:(id<KdbGroup>)group delegate:(id <ModalDelegate>)delegate
{
	if ((self = [super initWithStyle:UITableViewStyleGrouped]))
    {
        _delegate = delegate;
		_group = group;
		_av = [[ActivityView alloc] initWithFrame:CGRectMake(0,0,320,480)];			
		_op = [[FileManagerOperation alloc] initWithDelegate:self];
		_groupSectionHeader = [[GroupedSectionHeader alloc]initWithFrame:CGRectZero];
		_groupSectionHeader._label.text=NSLocalizedString(@"Entries", @"Entries");
		[_groupSectionHeader._button addTarget:self action:@selector(addEntry:) forControlEvents:UIControlEventTouchUpInside];		
		
		_entrySectionHeader = [[GroupedSectionHeader alloc]initWithFrame:CGRectZero];
		_entrySectionHeader._label.text=NSLocalizedString(@"Groups", @"Groups");
		[_entrySectionHeader._button addTarget:self action:@selector(addGroup:) forControlEvents:UIControlEventTouchUpInside];
		
		self.navigationItem.title = [_group getGroupName];
		self.tableView.allowsSelectionDuringEditing = YES;
		
		[self refreshData];
	}
	
	return self;
}

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];
	if([MyAppDelegate isEditable])
    {
		self.navigationItem.rightBarButtonItem = self.editButtonItem;		
	}
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _isRoot?1:2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(section==SECTION_GROUP){
		NSUInteger subGroupNum = [_subGroups count];
		return subGroupNum?subGroupNum:1;
	}else{
		NSUInteger entriesNum = [_entries count];
		return entriesNum?entriesNum:1;
	}
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"GroupCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
    [cell.imageView setImage:nil];
	if(indexPath.section==SECTION_GROUP){
		if(indexPath.row<[_subGroups count]){
			id<KdbGroup> group = (id <KdbGroup>)[_subGroups objectAtIndex:indexPath.row];
			cell.textLabel.text = [group getGroupName];
			cell.textLabel.textColor = [UIColor blackColor];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;			
            [cell.imageView setImage:[group getIcon]];
		}else{
			cell.textLabel.textColor = [UIColor grayColor];
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.textLabel.text = NSLocalizedString(@"No Child Groups", @"No Child Groups");
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
	}else{
		if(indexPath.row<[_entries count]){
			id<KdbEntry> entry = (id<KdbEntry>)[_entries objectAtIndex:indexPath.row];
			cell.textLabel.text = [entry getEntryName];
            if ([cell.textLabel.text length] == 0) cell.textLabel.text = [entry getUserName];
			cell.textLabel.textColor = [UIColor blackColor];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;			
            [cell.imageView setImage:[entry getIcon]];
		}else{
			cell.textLabel.textColor = [UIColor grayColor];			
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.textLabel.text = NSLocalizedString(@"No Entries", @"No Entries");
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
	}
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (!self.editing)
    {
		if (indexPath.section==SECTION_GROUP)
        { //group
			if (indexPath.row<[_subGroups count])
            {
				GroupViewController * group = [[GroupViewController alloc] initWithGroup:(id<KdbGroup>)[_subGroups objectAtIndex:indexPath.row] delegate:self];
				[self.navigationController pushViewController:group animated:YES];
			}
		}
        else
        { //entry
			if (indexPath.row<[_entries count])
            {
				EntryViewController *entry = [[EntryViewController alloc] initWithEntry:(id<KdbEntry>)[_entries objectAtIndex:indexPath.row] delegate:self];
				[self.navigationController pushViewController:entry animated:YES];
			}
		}
	}
    else
    { //editing mode
		if (indexPath.section == SECTION_GROUP)
        {
			if (indexPath.row<[_subGroups count])
            {
				EditNodeNameViewController *editNameViewController = [EditNodeNameViewController controllerWithDelegate:self];
				editNameViewController._group = (id<KdbGroup>)[_subGroups objectAtIndex:indexPath.row];
				UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:editNameViewController];
				[self presentModalViewController:navigationController animated:YES];
			}
		}
        else
        {
			if (indexPath.row<[_entries count])
            {
				EditNodeNameViewController *editNameViewController = [EditNodeNameViewController controllerWithDelegate:self];
				editNameViewController._entry = (id<KdbEntry>)[_entries objectAtIndex:indexPath.row];
				UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:editNameViewController];
				[self presentModalViewController:navigationController animated:YES];
			}
		}
		
	}
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		if(indexPath.section==SECTION_GROUP){
			if(indexPath.row<[_subGroups count]){
				if(_isRoot){ //we must have at least one group under root
					if([_subGroups count]==1){ 
						UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Error Deleting Group", @"Error Deleting Group")
																		message:NSLocalizedString(@"Cannot delete the last group", @"Cannot delete the last group") delegate:nil 
															  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
															  otherButtonTitles:nil];	
						[alert show];
						return;
					}
				}
				UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Deleting Group", @"Deleting Group")
																message:NSLocalizedString(@"Deleting a group will delete all its children. Are you sure to continue?", @"Group Deletion Confirmation") delegate:self 
													  cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
													  otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
				self._rowToDelete = indexPath;
				[alert show];
			}
		}else{
			if(indexPath.row<[_entries count]){
				[self.tableView beginUpdates];
				[_group deleteEntry:[_entries objectAtIndex:indexPath.row]];				
				[self refreshData];
				[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:NO];
				if([_entries count]==0){
					[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
				}
				[self.tableView endUpdates];
				MyAppDelegate.fileManager.dirty = YES;
			}
		}
    }   
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if(buttonIndex == 1 && _rowToDelete){
		[self.tableView beginUpdates];
		[_group deleteSubGroup:[_subGroups objectAtIndex:_rowToDelete.row]];
		[self refreshData];
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:_rowToDelete] withRowAnimation:NO];
		if([_subGroups count]==0){
			[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:_rowToDelete] withRowAnimation:YES];
		}
		[self.tableView endUpdates];
		MyAppDelegate.fileManager.dirty = YES;
		if(!self.editing){
			[self.view addSubview:_av];
			[_op performSelectorOnMainThread:@selector(save) withObject:nil waitUntilDone:NO];
		}
	}
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == SECTION_GROUP)
    {
		if(indexPath.row<[_subGroups count]){
			return UITableViewCellEditingStyleDelete;
		}else{
			return UITableViewCellEditingStyleNone;
		}
	}
    else
    {
		if (indexPath.row<[_entries count])
			return UITableViewCellEditingStyleDelete;
		else
			return UITableViewCellEditingStyleNone;
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	if (section==SECTION_ENTRY)
    {
		_groupSectionHeader._button.hidden = self.editing?![MyAppDelegate isEditable]:YES;
		return self._groupSectionHeader;
	}
    else
    {
		_entrySectionHeader._button.hidden = self.editing?![MyAppDelegate isEditable]:YES;
		return self._entrySectionHeader;
	}
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 44;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animate
{
	[super setEditing:editing animated:YES];
	if(self.editing)
    {
		_groupSectionHeader._button.hidden = _entrySectionHeader._button.hidden = ![MyAppDelegate isEditable];
		[self.navigationItem setHidesBackButton:YES animated:YES];
	}
    else
    {
		_groupSectionHeader._button.hidden = YES;
		_entrySectionHeader._button.hidden = YES;		
		[self.navigationItem setHidesBackButton:NO animated:YES];

		if (MyAppDelegate.fileManager.dirty)
        {
			[self.view addSubview:_av];
			[_op performSelectorInBackground:@selector(save) withObject:nil];
		}
	}
}

- (IBAction)addEntry:(id)sender
{
	NewEntryViewController *  entryViewController = [NewEntryViewController controllerWithDelegate:self];
	entryViewController._parent = _group;
	UINavigationController *  navigationController = [[UINavigationController alloc]initWithRootViewController:entryViewController];
	[self presentModalViewController:navigationController animated:YES];
}


- (IBAction)addGroup:(id)sender
{
	NewGroupViewController *  groupViewController = [NewGroupViewController controllerWithDelegate:self];
	groupViewController._parent = _group;
	UINavigationController *  navigationController = [[UINavigationController alloc]initWithRootViewController:groupViewController];
	[self presentModalViewController:navigationController animated:YES];
}

- (void)dismissModalViewCancel:(id)controller
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void)dismissModalViewOK:(id)controller
{
	[self dismissModalViewControllerAnimated:YES];
	[self refreshData];
	[self.tableView reloadData];
}

- (void)refreshData
{
	self._subGroups = [[_group getSubGroups] sortedArrayUsingFunction:groupSort context:nil];
	self._entries = [[_group getEntries] sortedArrayUsingFunction:entrySort context:nil];
}

- (void)fileOperationSuccess
{
	[_av removeFromSuperview];	
}

- (void)fileOperationFailureWithException:(NSException *)exception
{
	[_av removeFromSuperview];
	UIAlertView * alert = [[UIAlertView alloc]initWithTitle:nil 
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

