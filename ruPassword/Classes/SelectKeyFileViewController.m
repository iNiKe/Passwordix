//
//  SelectKeyFileViewController.m
//  ruPassword
//
//  Created by Nikita Galayko on 10.03.13.
//  Copyright (c) 2013 Galayko.ru. All rights reserved.
//

#import "SelectKeyFileViewController.h"
#import "FileManager.h"

@interface SelectKeyFileViewController ()

@end

@implementation SelectKeyFileViewController
@synthesize selectedFile;

+ (id)controllerWithDelegate:(id <ModalDelegate>)delegate
{
    return [[SelectKeyFileViewController alloc] initWithDelegate:delegate];
}

- (id)initWithDelegate:(id <ModalDelegate>)delegate
{
    if ((self = [self initWithStyle:UITableViewStylePlain]))
    {
        _delegate = delegate;
    }
    return self;
}

- (void)reloadFiles
{
    _files = [NSMutableArray array];

	NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *docsDir = (NSString *)[paths objectAtIndex:0];
    NSString *docsDir = [FileManager dataDir];
	NSArray *contents = [fileManager contentsOfDirectoryAtPath:docsDir error:&error];
	for (NSString *fileName in contents)
    {
		if(![fileName hasPrefix:@"."])
        {
            if (!([[fileName pathExtension]  caseInsensitiveCompare:@"kdb"] == NSOrderedSame)||([[fileName pathExtension]  caseInsensitiveCompare:@"kdbx"] == NSOrderedSame))
                [_files addObject:[docsDir stringByAppendingPathComponent:fileName]];
		}
	}
	[_files sortUsingSelector:@selector(caseInsensitiveCompare:)];
    [_files insertObject:NSLocalizedString(@"<none>", nil) atIndex:0];
    [self.tableView reloadData];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self reloadFiles];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _files.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}

//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSString *fileName = [_files objectAtIndex:indexPath.row];
    cell.textLabel.text = [fileName lastPathComponent];
    if ( (selectedFile && [fileName isEqualToString:selectedFile]) || (!selectedFile && indexPath.row == 0) )
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    selectedFile = [_files objectAtIndex:indexPath.row];
    [_delegate dismissModalViewOK:self];
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
