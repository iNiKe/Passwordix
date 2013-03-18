//
//  NewGroupViewController.h
//  MyKeePass
//
//  Created by Qiang Yu on 3/14/10.
//  Copyright 2010 Qiang Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <KdbLib.h>

@interface NewGroupViewController : UITableViewController
{
	id<KdbGroup> _parent;	
    __unsafe_unretained id<ModalDelegate> _delegate;
}

@property (nonatomic, strong) id<KdbGroup> _parent;

- (IBAction)cancelClicked:(id)sender;
- (IBAction)doneClicked:(id)sender;
+ (id)controllerWithDelegate:(id <ModalDelegate>)delegate;

@end
