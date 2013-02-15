//
//  OSOdnoklassniki.m
//  Odnoklassniki
//
//  Created by Roman Kosko on 01.02.13.
//  Copyright (c) 2013 Nuclominus. All rights reserved.
//

#import "OSOdnoklassniki.h"


@interface OSOdnoklassniki()<ASIHTTPRequestDelegate>

@end


@implementation OSOdnoklassniki

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

// сериализация url запроса
+ (NSString*)serializeURL:(NSString *)baseUrl params:(NSDictionary *)params httpMethod:(NSString *)httpMethod{
    
    NSURL* parsedURL = [NSURL URLWithString:baseUrl];
	NSString* queryPrefix = parsedURL.query ? @"&" : @"?";
    
	NSMutableArray* pairs = [NSMutableArray array];
	for (NSString* key in [params keyEnumerator]) {
		NSString* escaped_value = (NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                      NULL, /* allocator */
                                                                                      (CFStringRef)[params objectForKey:key],
                                                                                      NULL, /* charactersToLeaveUnescaped */
                                                                                      (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                      kCFStringEncodingUTF8);
        
		[pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escaped_value]];
	}
	NSString* query = [pairs componentsJoinedByString:@"&"];
    
	return [NSString stringWithFormat:@"%@%@%@", baseUrl, queryPrefix, query];
}


// запрос на авторизацию
// после авторизации сервер возвращет список параметров для составления подписи

- (void)requestToken:(NSURLRequest *)request{
    
    
    NSString *code = [[[[request.URL.absoluteString componentsSeparatedByString:@"?"] objectAtIndex:1] componentsSeparatedByString:@"="] lastObject];
    NSLog(@"CODE = %@",code);
    
    
    ASIFormDataRequest *getTokenRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.odnoklassniki.ru/oauth/token.do"]]];
    
    [getTokenRequest setTag:0]; // установка тэга запросу, позволяет распознать ответ 
    [getTokenRequest addPostValue:code forKey:@"code"]; // заголовок запроса
    [getTokenRequest addPostValue:_clientID  forKey:@"client_id"]; // ID клиента
    [getTokenRequest addPostValue:_appSecretKey forKey:@"client_secret"]; // Секретный ключ
    [getTokenRequest addPostValue:@"authorization_code" forKey:@"grant_type"]; 
    [getTokenRequest addPostValue:@"ok127410176" forKey:@"redirect_uri"]; // url колбэка
    [getTokenRequest setDelegate:self];
    [getTokenRequest startAsynchronous]; // посылка асинхронного запроса
    
}


// Запрос с использованием  RestAPI Однокласников //
// На вход принимает: тип запроса (GET/POST), RestAPI (), набор требуеммых параметров, тэг запроса для индетификации ответа //

- (void) requestAPIData:(NSString*)methodReq requestRestAPI:(NSString*)api withParams:(NSDictionary*)params withTagOfRequest:(int)tag{
    
    _appToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"OdnoklassnikiToken"];
    
    NSMutableDictionary *newParams = [NSMutableDictionary dictionaryWithDictionary:params];  // набор параметров
    [newParams setValue:_appPublicKey forKey:@"application_key"]; // публичный ключ приложения
    NSString *signature = [self getSignatureForParams:newParams withAccessToken:_appToken andSecret:_appSecretKey]; // подпись/сигнатура, которой должны быть подписаны все запросы на получение данных
    [newParams setValue:signature forKey:@"sig"];
    [newParams setValue:_appToken forKey:@"access_token"];
    NSString * apiMethod =[NSString stringWithFormat:@"%@",api] ; // RestAPI
    NSString *method = [apiMethod stringByReplacingOccurrencesOfString:@"." withString:@"/"];
    NSString * url = [OSOdnoklassniki serializeURL:[NSString stringWithFormat:@"%@%@", @"http://api.odnoklassniki.ru/api/", method] params:newParams httpMethod:_httpMethod]; // последняя стадия составления запроса - сериализация url
    
    ASIFormDataRequest * request_data;
    request_data = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    [request_data setTag:tag];
    [request_data setDelegate:self];
    [request_data setRequestMethod:methodReq];
    [request_data startAsynchronous];
    
    
}



// метод принемающий ответ от сервера
- (void)requestFinished:(ASIHTTPRequest *)request {
    
    NSLog(@"REQUEST ID = %d",request.tag);
    NSDictionary *respone = [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingMutableLeaves error:nil];
    
    NSLog(@"%@",respone);
    
    if(request.tag == 0) {
        [[NSUserDefaults standardUserDefaults] setObject:[respone objectForKey:@"access_token"] forKey:@"OdnoklassnikiToken"];
        [[NSUserDefaults standardUserDefaults] setObject:[respone objectForKey:@"refresh_token"] forKey:@"OdnoklassnikiRefreshToken"];
        [_delegate showUp:self];
        
    }
    
    if (request.tag == 1) {
        // запрос на данные по списку 
        dataRequest = [NSArray arrayWithObjects:respone,nil];
        NSString * friendsString = [dataRequest componentsJoinedByString:@","];
        
        [self requestAPIData:@"GET" requestRestAPI:@"users.getInfo" withParams:[NSDictionary dictionaryWithObjects: [ NSArray arrayWithObjects:friendsString,@"first_name,last_name,birthday,name,pic_3,pic_2,pic_1,location", nil] forKeys:[NSArray arrayWithObjects:@"uids",@"fields", nil]] withTagOfRequest:2];
        
    }
    
    if (request.tag == 2) {
        // преобразование списков
        _data = [NSMutableArray array];
        for (NSDictionary * dict in respone) {
            NSDictionary * convert = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:[dict objectForKey:@"birthday"],[dict objectForKey:@"first_name"],[dict objectForKey:@"last_name"],[[dict objectForKey:@"location"] objectForKey:@"city"],[[dict objectForKey:@"location"] objectForKey:@"country"],[dict objectForKey:@"name"],[dict objectForKey:@"pic_3"],[dict objectForKey:@"pic_2"],[dict objectForKey:@"pic_1"],[dict objectForKey:@"uid"] ,nil] forKeys:[NSArray arrayWithObjects:@"bdate",@"first_name",@"last_name",@"city",@"country",@"nickname",@"photo_big",@"photo_medium",@"photo",@"uid", nil]];
            [_data addObject:convert];
            [convert release];
        }
        
        NSLog(@"DATA = %@",_data);
    }
    
}

- (NSArray*) getDataRequest{
    return dataRequest;
}


// составление сигнатуры подписи
- (NSString *)getSignatureForParams:(NSDictionary *)params withAccessToken:(NSString *)accessToken andSecret:(NSString *)secretKey{
	NSArray *sortedKeys = [[params allKeys] sortedArrayUsingSelector: @selector(compare:)];
	NSMutableString *signatureString = [NSMutableString stringWithString:@""];
	for (int i =0; i<sortedKeys.count; i++){
		NSString *key = [sortedKeys objectAtIndex:i];
		[signatureString appendString:[NSString stringWithFormat:@"%@=%@", key, [params valueForKey:key]]];
	}
    
	[signatureString appendString:mmd5([NSString stringWithFormat:@"%@%@", accessToken, secretKey])];
	return [mmd5(signatureString) lowercaseString];
}

// кодирование в md5
NSString* mmd5(NSString* str) {
	const char *cStr = [str UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
    
	CC_MD5( cStr, strlen(cStr), result );
    
	return [[NSString
             stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0],  result[1],
             result[2],  result[3],
             result[4],  result[5],
             result[6],  result[7],
             result[8],  result[9],
             result[10], result[11],
             result[12], result[13],
             result[14], result[15]
             ] lowercaseString];
}

- (void)dealloc
{
    [super dealloc];
}



@end
