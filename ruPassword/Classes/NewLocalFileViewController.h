//
//  NewLocalFileViewController.h
//  MyKeePass
//
//  Created by Qiang Yu on 3/4/10.
//  Copyright 2010 Qiang Yu. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NewLocalFileViewController : UITableViewController <UIAlertViewDelegate>
{
    __unsafe_unretained id<ModalDelegate> _delegate;
}

- (IBAction)cancelClicked:(id)sender;
- (IBAction)doneClicked:(id)sender;
+ (id)controllerWithDelegate:(id<ModalDelegate>)delegate;

@end
