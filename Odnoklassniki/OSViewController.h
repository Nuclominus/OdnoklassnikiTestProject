//
//  OSViewController.h
//  Odnoklassniki
//
//  Created by Roman Kosko on 12.02.13.
//  Copyright (c) 2013 Nuclominus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSOdnoklassniki.h"

@interface OSViewController : UIViewController<UIApplicationDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate,OdnoklassnikiDelegate,UIWebViewDelegate>
{
    IBOutlet UIWebView * oauthWeb;
    OSOdnoklassniki * apiOK;
}

@property (assign,nonatomic) IBOutlet UIWebView * oauthWeb;
@property (assign,nonatomic) id delegate;

@end
