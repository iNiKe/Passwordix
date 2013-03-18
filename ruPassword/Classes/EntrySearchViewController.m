//
//  EntrySearchViewController.m
//  MyKeePass
//
//  Created by Qiang Yu on 3/22/10.
//  Copyright 2010 Qiang Yu. All rights reserved.
//

#import "EntrySearchViewController.h"
#import "Sort.h"
#import "EntryViewController.h"
//#import "MyKeePassAppDelegate.h"

@interface EntrySearchViewController (PrivateMethod)
- (void)addEntries:(id<KdbGroup>) group toArray:(NSMutableArray *)entries;
- (void)filterEntriesForSearchText:(NSString*)searchText;
@end


@implementation EntrySearchViewController
@synthesize _entries;
@synthesize _qualifiedEntries;
@synthesize _group;
@synthesize searchDisplayController;

- (void)dismissModalViewCancel:(id)controller
{
    
}

- (void)dismissModalViewOK:(id)controller
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData:) name:@"EntryUpdated" object:nil];	
	UISearchBar * searchBar = [[UISearchBar alloc] init];
	
	searchBar.delegate = self;
	[searchBar sizeToFit];
	self.tableView.tableHeaderView = searchBar;
	self.tableView.tableHeaderView.frame = CGRectMake(0, 0, 320, 44);
	
	searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];	
	[searchDisplayController setDelegate:self];
	[searchDisplayController setSearchResultsDelegate:self];
	[searchDisplayController setSearchResultsDataSource:self];
	
	[self refreshData:nil];
	self.tableView.scrollEnabled = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.searchDisplayController = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return (tableView == self.searchDisplayController.searchResultsTableView) ? [self._qualifiedEntries count] : [self._entries count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
    id <KdbEntry> entry = (tableView == self.searchDisplayController.searchResultsTableView) ? [_qualifiedEntries objectAtIndex:indexPath.row] : [_entries objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [entry getEntryName];
    cell.detailTextLabel.text = [entry getUserName];
    [cell.imageView setImage:[entry getIcon]];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	EntryViewController * entry = nil;
	
	if(tableView == self.searchDisplayController.searchResultsTableView){
		entry = [[EntryViewController alloc] initWithEntry:(id<KdbEntry>)[_qualifiedEntries objectAtIndex:indexPath.row] delegate:self];
	}else{
		entry = [[EntryViewController alloc] initWithEntry:(id<KdbEntry>)[_entries objectAtIndex:indexPath.row] delegate:self];
	}

	[self.navigationController pushViewController:entry animated:YES];
}

-(void)addEntries:(id<KdbGroup>) group toArray:(NSMutableArray *)entries{
	id<KdbTree> tree = [MyAppDelegate.fileManager.kdbReader getKdbTree];
	// skip entries in recycle bins
	if([tree isRecycleBin:group]) return;
	
	[entries addObjectsFromArray:[group getEntries]];
	for(id<KdbGroup> sg in [group getSubGroups]){
		[self addEntries:sg toArray:entries];
	}
}

#pragma mark -
#pragma mark Content Filtering

- (void)filterEntriesForSearchText:(NSString*)searchText
{
	[_qualifiedEntries removeAllObjects];
	
	for (id<KdbEntry> entry in _entries)
    {
		NSRange range = [[entry getEntryName] rangeOfString:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)];
		if([[entry getEntryName] length]&&range.location!=NSNotFound)
        {
			[_qualifiedEntries addObject:entry];
		}else{
			range = [[entry getUserName] rangeOfString:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)];
			if([[entry getUserName] length]&&range.location!=NSNotFound)
            {
				[_qualifiedEntries addObject:entry];
			}
		}
	}
	
	NSLog(@"%d", [_qualifiedEntries count]);
}


#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterEntriesForSearchText:searchString];
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterEntriesForSearchText:[self.searchDisplayController.searchBar text]];
    return YES;
}

- (void)refreshData:(NSNotification *)notification
{
	//NSLog(@"refresh");
	if (!_entries)
    {
		_entries = [[NSMutableArray alloc]initWithCapacity:24];
	}else{
		[_entries removeAllObjects];
	}
	
	if(!_qualifiedEntries){
		_qualifiedEntries = [[NSMutableArray alloc]initWithCapacity:24];
	}else{
		[_qualifiedEntries removeAllObjects];
	}
	
	NSMutableArray * entries = [[NSMutableArray alloc]initWithCapacity:24];
	
	[self addEntries:_group toArray:entries];	
	
	[self._entries addObjectsFromArray:[entries sortedArrayUsingFunction:entrySort context:nil]];	
	
	[self.tableView reloadData];
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

