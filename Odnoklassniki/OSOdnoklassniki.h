//
//  OSOdnoklassniki.h
//  Odnoklassniki
//
//  Created by Roman Kosko on 01.02.13.
//  Copyright (c) 2013 Nuclominus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import <CommonCrypto/CommonCrypto.h>

@class OSOdnoklassniki;


@protocol OdnoklassnikiDelegate <NSObject>

@optional
- (void)showUp:(OSOdnoklassniki*) api;
@end

@interface OSOdnoklassniki : NSObject<UIApplicationDelegate,NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
//    
//    NSString * _clientID,     * _appPublicKey,
//             * _appSecretKey, * _appToken,
//             * _httpMethod,   * _redirectURI;
//    
    NSArray * dataRequest;
    NSMutableArray * _data;
}

@property (assign,nonatomic) NSString * clientID;
@property (assign,nonatomic) NSString * appPublicKey;
@property (assign,nonatomic) NSString * appSecretKey;
@property (assign,nonatomic) NSString * appToken;
@property (assign,nonatomic) NSString * httpMethod;
@property (assign,nonatomic) NSString * redirectURI;
@property (assign,nonatomic) NSMutableArray * data;
@property (assign,nonatomic) id delegate;

+ (NSString*)serializeURL:(NSString *)baseUrl params:(NSDictionary *)params httpMethod:(NSString *)httpMethod;
- (void)requestToken:(NSURLRequest *)request;
- (void) requestAPIData:(NSString*)methodReq requestRestAPI:(NSString*)api withParams:(NSDictionary*)params withTagOfRequest:(int)tag;
- (NSArray*) getDataRequest;

@end
