//
//  SelectKeyFileViewController.h
//  ruPassword
//
//  Created by Nikita Galayko on 10.03.13.
//  Copyright (c) 2013 Galayko.ru. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectKeyFileViewController : UITableViewController
{
    __unsafe_unretained id<ModalDelegate> _delegate;
    NSMutableArray *_files;
}
@property (nonatomic, strong) NSString *selectedFile;

+ (id)controllerWithDelegate:(id <ModalDelegate>)delegate;

@end
