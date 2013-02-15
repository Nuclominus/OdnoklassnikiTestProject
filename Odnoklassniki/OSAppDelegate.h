//
//  OSAppDelegate.h
//  Odnoklassniki
//
//  Created by Roman Kosko on 12.02.13.
//  Copyright (c) 2013 Nuclominus. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSViewController;

@interface OSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) OSViewController *viewController;

@end
