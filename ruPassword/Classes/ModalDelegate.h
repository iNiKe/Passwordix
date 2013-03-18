//
//  ModalDelegate.h
//  ruPassword
//
//  Created by Nikita Galayko on 02.03.13.
//  Copyright (c) 2013 Galayko.ru. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ModalDelegate <NSObject>

- (void)dismissModalViewOK:(id)controller;

@optional

- (void)dismissModalViewCancel:(id)controller;

@end
