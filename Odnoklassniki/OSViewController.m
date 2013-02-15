//
//  OSViewController.m
//  Odnoklassniki
//
//  Created by Roman Kosko on 12.02.13.
//  Copyright (c) 2013 Nuclominus. All rights reserved.
//

#import "OSViewController.h"

static NSString * appID = @"********";
static NSString * appSecret = @"******************";
static NSString * appKey = @"*****************";

@interface OSViewController () <ASIHTTPRequestDelegate>

@end

@implementation OSViewController

@synthesize  oauthWeb = _oauthWeb;


- (void)authenticationOk{
//    apiOK.delegate = self;
//    apiOK.clientID = appID;
//    apiOK.appPublicKey = appKey;
//    apiOK.appSecretKey = appSecret;
    
	NSString *authString = @"http://www.odnoklassniki.ru/oauth/authorize?client_id=********&response_type=code&redirect_uri=ok*********";
	NSURL *authURL = [[NSURL alloc] initWithString:authString];
	NSURLRequest *authRequest = [[NSURLRequest alloc] initWithURL:authURL];
	[_oauthWeb loadRequest:authRequest];
    
}

- (void)logOut{
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [self authenticationOk];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _oauthWeb.scalesPageToFit = TRUE;
    
    apiOK = [[OSOdnoklassniki alloc]init];
    apiOK.delegate = self;
    _oauthWeb.delegate = self;
    apiOK.clientID = appID;
    apiOK.appPublicKey = appKey;
    apiOK.appSecretKey = appSecret;
    
    [self authenticationOk];
    
}

// метод для соcтавления и посылки запроса на получение токена
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    if([request.URL.absoluteString rangeOfString:@"ok*********/"].location != NSNotFound) {
        NSLog(@"shouldStartLoadWithRequest =%@", request);
        
            [apiOK requestToken:request];
            
            NSLog(@"DATA REQUEST = %@",[apiOK getDataRequest]);
        }
        
        
    return YES;
}


- (void) showUp:(OSOdnoklassniki *)api{
    [apiOK requestAPIData:@"GET" requestRestAPI:@"friends.get" withParams:nil withTagOfRequest:1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
