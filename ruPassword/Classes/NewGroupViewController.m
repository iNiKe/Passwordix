//
//  NewGroupViewController.m
//  MyKeePass
//
//  Created by Qiang Yu on 3/14/10.
//  Copyright 2010 Qiang Yu. All rights reserved.
//

#import "NewGroupViewController.h"
#import "TKLabelTextFieldCell.h"
#import "TKTextViewCell.h"

@implementation NewGroupViewController
@synthesize _parent;

+ (id)controllerWithDelegate:(id <ModalDelegate>)delegate
{
    return [[NewGroupViewController alloc] initWithDelegate:delegate];
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
	
	self.navigationItem.title = NSLocalizedString(@"Add Group", @"Add Group");
	
	self.navigationItem.leftBarButtonItem = cancel;
	
	UIBarButtonItem * done = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Done", @"Done") 
															 style:UIBarButtonItemStyleDone target:self action:@selector(doneClicked:)];
	self.navigationItem.rightBarButtonItem = done;

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	TKLabelTextFieldCell * cell = (TKLabelTextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];		
	[cell.field becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"NewGroupCell";
    
	TKLabelTextFieldCell *cell = (TKLabelTextFieldCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[TKLabelTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	}
    
	cell.field.secureTextEntry = NO;
	cell.field.text = @"";
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.field.placeholder = NSLocalizedString(@"Group Name", @"Group Name");
	
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	return NSLocalizedString(@"Group Name", @"Group Name");
}

- (IBAction)cancelClicked:(id)sender
{
    [_delegate dismissModalViewCancel:self];
}

- (IBAction)doneClicked:(id)sender
{
    [Flurry logEvent:@"KDB.New.Group.OK"];
	FileManager * fm = MyAppDelegate.fileManager;
	
	if([fm getKDBVersion]==KDB_VERSION1){
		TKLabelTextFieldCell * cell = (TKLabelTextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];		
		if([cell.field.text isEqualToString:@"Backup"]){
			UIAlertView * alert = [[UIAlertView alloc]initWithTitle:nil 
															message:NSLocalizedString(@"Group name is reserved", @"Group name is reserved") delegate:nil 
												  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
												  otherButtonTitles:nil];	
			[alert show];
			return;
		}
		Kdb3Group * group =  [[Kdb3Group alloc]init];		
		group._title = cell.field.text;
		
		NSDate * now = [NSDate date];
		[group setExpiry:nil];
		[group setLastMod:now];
		[group setLastAccess:now];
		[group setCreation:now];
		
		[_parent addSubGroup:group];			
		fm.dirty = YES;
	}
    [_delegate dismissModalViewOK:self];
}

@end

