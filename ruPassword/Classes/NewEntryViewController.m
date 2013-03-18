//
//  NewEntryTableViewController.m
//  MyKeePass
//
//  Created by Qiang Yu on 3/12/10.
//  Copyright 2010 Qiang Yu. All rights reserved.
//

#import "NewEntryViewController.h"

#define ENTRY_NAME_ROW	0
#define USERNAME_ROW	1
#define PASSWORD_ROW1	2
#define PASSWORD_ROW2	3
#define WEBSITE_ROW		4

#define COMMENT_ROW		0

@implementation NewEntryViewController
@synthesize _parent;
@synthesize _entryname;
@synthesize _username;
@synthesize _password1;
@synthesize _password2;
@synthesize _url;
@synthesize _comment;

+ (id)controllerWithDelegate:(id <ModalDelegate>)delegate
{
    return [[NewEntryViewController alloc] initWithDelegate:delegate];
}

- (id)initWithDelegate:(id <ModalDelegate>)delegate
{
    if ((self = [self initWithStyle:UITableViewStyleGrouped]))
    {
        _delegate = delegate;
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	[_entryname.field becomeFirstResponder];
}

- (void)viewDidLoad
{
	[super viewDidLoad];	
	self.navigationItem.title = NSLocalizedString(@"Add Entry", @"Add Entry");

	UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelClicked:)];
	self.navigationItem.leftBarButtonItem = cancel;
	
	UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done") style:UIBarButtonItemStyleDone target:self action:@selector(doneClicked:)];
	self.navigationItem.rightBarButtonItem = done;
	
	_entryname = [[TKLabelTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	_entryname.field.placeholder = NSLocalizedString(@"Entry Name", @"Entry Name");
	_entryname.field.text = @"";
	_entryname.selectionStyle = UITableViewCellSelectionStyleNone;
	
	_username = [[TKLabelTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	_username.field.placeholder = NSLocalizedString(@"User Name", @"User Name");
	_username.field.text = @"";
	_username.selectionStyle = UITableViewCellSelectionStyleNone;
	
	_password1 = [[TKLabelTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	_password1.field.placeholder = NSLocalizedString(@"Password", @"Password");
	_password1.field.text = @"";
	_password1.field.secureTextEntry = YES;
	_password1.selectionStyle = UITableViewCellSelectionStyleNone;
	
	_password2 = [[TKLabelTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	_password2.field.placeholder = NSLocalizedString(@"Password", @"Password");
	_password2.field.text = @"";
	_password2.field.secureTextEntry = YES;
	_password2.selectionStyle = UITableViewCellSelectionStyleNone;
	
	_url = [[TKLabelTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	_url.field.placeholder = NSLocalizedString(@"URL", @"URL");
	_url.field.text = @"";
	_url.selectionStyle = UITableViewCellSelectionStyleNone;
	_url.field.keyboardType = UIKeyboardTypeURL;
	_url.field.autocapitalizationType = UITextAutocapitalizationTypeNone;
	
	_comment = (TKTextViewCell *)[[TKTextViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	_comment.textView.text = @"";	
	_comment.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
	self._entryname = nil; self._username = nil; self._password1 = nil; self._password2 = nil; self._url = nil; self._comment = nil;
	[super viewDidUnload];
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0)
		return 5;
	else 
		return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([indexPath section] == 0)
    {
		switch (indexPath.row)
        {
			case ENTRY_NAME_ROW:
				return _entryname;
			case USERNAME_ROW:
				return _username;
			case PASSWORD_ROW1:
				return _password1;
			case PASSWORD_ROW2:
				return _password2;
			case WEBSITE_ROW:
				return _url;
			default:
				return nil;
		}
	}
    else
    {
		return _comment;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([indexPath section] == 0) 
		return 40;
	else	
		return 150;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section==0) 
		return NSLocalizedString(@"Entry Fields", @"Entry Fields");
	else {
		return NSLocalizedString(@"Comment", "Comment");
	}
}

- (IBAction)cancelClicked:(id)sender
{
    [_delegate dismissModalViewCancel:self];
}

- (IBAction)doneClicked:(id)sender
{
    [Flurry logEvent:@"KDB.New.Entry.OK"];
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
		FileManager *fm = MyAppDelegate.fileManager;
		if ([fm getKDBVersion]==KDB_VERSION1)
        {
			Kdb3Entry *entry = [[Kdb3Entry alloc] initWithNewUUID];
			
			entry._title = _entryname.field.text;
			entry._username = _username.field.text;
			entry._password = _password1.field.text;
			entry._url = _url.field.text;
			entry._comment = _comment.textView.text;
			
			NSDate *now = [NSDate date];
			[entry setExpiry:nil];
			[entry setLastMod:now];
			[entry setLastAccess:now];
			[entry setCreation:now];
			
			[_parent addEntry:entry];			
			fm.dirty = YES;
		}
		[[NSNotificationCenter defaultCenter] postNotificationName:@"EntryUpdated" object:nil];
        [_delegate dismissModalViewOK:self];
	}
}

@end
