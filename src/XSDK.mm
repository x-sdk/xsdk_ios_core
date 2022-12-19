//
//  XSDK.mm
//  core
//  SDK管理类
//  Created by yuangu on 2021/6/23.
//

#import <Foundation/Foundation.h>
#include "XSDK.h"

@implementation XSDK{
    NSMutableDictionary* mShareSDKMap;
    NSMutableDictionary* mPaySDKMap;
    NSMutableDictionary* mLoginSDKMap;
    NSMutableDictionary* mPushSDKMap;
    id<IPushCallback> mPushCallback;
}

static XSDK*  mInstace = nil;

+ (XSDK*)getInstance
{
    @synchronized(self.class)
    {
        if (mInstace == nil) {
            mInstace = [[self.class alloc] init];
        }
        
        return mInstace;
    }
}

-(id)init
{
    if(self=[super init])
    {
        self->mShareSDKMap = [NSMutableDictionary  dictionaryWithCapacity:0];
        self->mPaySDKMap = [NSMutableDictionary  dictionaryWithCapacity:0];
        self->mLoginSDKMap = [NSMutableDictionary  dictionaryWithCapacity:0];
        self->mPushSDKMap = [NSMutableDictionary  dictionaryWithCapacity:0];
    }
    return self;
}

-(void) doInUIThread:(dispatch_block_t) block
{
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(),  block);
    }
}

-(bool) hasSDK:(NSString*) sdkName :(NSString*) sdkType
{
    if ( [sdkType isEqual:@"oauth" ]) {
        return [self->mLoginSDKMap objectForKey:sdkName] != nil;
        
    } else if ([sdkType isEqual:@"share"]) {
        return [self->mShareSDKMap objectForKey:sdkName] != nil;
    } else if ([sdkType isEqual:@"payment"]) {
        return  [self->mPaySDKMap objectForKey:sdkName] != nil;
    } else if ([sdkType isEqual:@"push"]) {
        
    } else if ([sdkType isEqual:@"ad"]) {
        
    }  else if ([sdkType isEqual:@"event"]) {
        
    }
    return false;
}

-(void) initSDK:(SDKParams*) params :(id<IXSDKCallback>)callBack
{
    [self doInUIThread: ^{
        if([@"oauth" isEqual:params.service]) {
            id<ISDK> object = [self->mLoginSDKMap objectForKey:params.provider];
            if(object != nil){
                [object initSDK:params:callBack];
                return;
            }
            
        } else  if([@"share" isEqual:params.service])  {
            id<ISDK> object = [self->mShareSDKMap objectForKey:params.provider];
            if(object != nil){
                [object initSDK:params:callBack];
                return;
            }
        } else  if([@"payment" isEqual:params.service])  {
            id<ISDK> object = [self->mPaySDKMap objectForKey:params.provider];
            if(object != nil){
                [object initSDK:params:callBack];
                return;
            }
        } else if([@"push" isEqual:params.service]) {
            
        }else{
            id<ISDK> object = [self->mLoginSDKMap objectForKey:params.provider];
            if(object != nil){
                [object initSDK:params:callBack];
                return;
            }
            
            object = [self->mShareSDKMap objectForKey:params.provider];
            if(object != nil){
                [object initSDK:params:callBack];
                return;
            }
            
            object = [self->mPaySDKMap objectForKey:params.provider];
            if(object != nil){
                [object initSDK:params:callBack];
                return;
            }
            
            [callBack onFaild: [[NSString alloc] initWithFormat:@"%@,%@", @"no Found SDK:", params.service ]];
        }
    }];
}

-(void) login:(LoginParams*) params :(id<IXSDKCallback>)callBack
{
    [self doInUIThread: ^{
        id<ILogin> object = [self->mLoginSDKMap objectForKey:params.provider];
        if(object != nil){
            [object login:params:callBack];
            return;
        }
        NSLog(@"xsdk not found %@", params.provider);
    }];
}

-(void) logout:(LogoutParams*) params :(id<IXSDKCallback>)callBack{
    [self doInUIThread: ^{
        id<ILogin> object = [self->mLoginSDKMap objectForKey:params.provider];
        if(object != nil){
            [object logout:params:callBack];
            return;
        }
        NSLog(@"xsdk not found %@", params.provider);
    }];
}


-(void) pay:(PayParams*) params :(id<IXSDKCallback>)callBack
{
    [self doInUIThread: ^{
        id<IPay> object = [self->mPaySDKMap objectForKey:params.provider];
        if(object != nil){
            [object pay: params:callBack];
            return;
        }
        NSLog(@"xsdk not found %@", params.provider);
    }];
}

-(void) share:(ShareParams*) params :(id<IXSDKCallback>)callBack
{
    [self doInUIThread: ^{
        id<IShare> object = [self->mShareSDKMap objectForKey:params.provider];
        if(object != nil){
            [object share: params:callBack];
            return;
        }
        NSLog(@"xsdk not found %@", params.provider);
    }];
}

+(bool) hasSDK:(NSString*) json
{
    NSData *jsonData =  [json dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                         options:NSJSONReadingMutableContainers
                                                           error:nil];
    return [[XSDK getInstance] hasSDK:[dict objectForKey:@"provider"] :[dict objectForKey:@"service" ]];
}

+(void) initSDK:(NSString*) json :(id<IXSDKCallback>)callBack
{
    NSData *jsonData =  [json dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                         options:NSJSONReadingMutableContainers
                                                           error:nil];
    SDKParams *params = [[SDKParams alloc] init];
    [params setValuesForKeysWithDictionary:dict];
    
    [[XSDK getInstance] initSDK:params :callBack];
}

+(void) login:(NSString*) json :(id<IXSDKCallback>)callBack{
    NSData *jsonData =  [json dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                         options:NSJSONReadingMutableContainers
                                                           error:nil];
    LoginParams *params = [[LoginParams alloc] init];
    [params setValuesForKeysWithDictionary:dict];
    
    [[XSDK getInstance] login:params :callBack];
}

+(void) logout:(NSString*) json :(id<IXSDKCallback>)callBack{
    NSData *jsonData =  [json dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                         options:NSJSONReadingMutableContainers
                                                           error:nil];
    LogoutParams *params = [[LogoutParams alloc] init];
    [params setValuesForKeysWithDictionary:dict];
    
    [[XSDK getInstance] logout:params :callBack];
}

+(void) pay:(NSString*) json :(id<IXSDKCallback>)callBack
{
    NSData *jsonData =  [json dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                         options:NSJSONReadingMutableContainers
                                                           error:nil];
    
    PayParams *params = [[PayParams alloc] init];
    [params setValuesForKeysWithDictionary:dict];
    [[XSDK getInstance] pay:params :callBack];
}

+(void) share:(NSString*) json :(id<IXSDKCallback>)callBack
{
    NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys: nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:nil];
    NSString* ret = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [callBack onSucess:ret];
}

//========================================================
- (void) setPushCallBack:(id<IPushCallback>)callback{
    mPushCallback = callback;
}

- (id<IPushCallback>) getPushCallBack{
    return mPushCallback;
}

+(void)onPush:(id<IPushCallback>)callback {
    [[XSDK getInstance] setPushCallBack:callback];
}
//========================================================

- (void) forLogin:(NSString *)provider :(id<ILogin>) obj
{
    [ self->mShareSDKMap setObject:obj forKey:provider];
}

- (void) forPay:(NSString *)provider :(id<IPay>) obj
{
    [ self->mPaySDKMap setObject:obj forKey:provider];
}

- (void) forShare:(NSString *)provider :(id<IShare>)  obj
{
    [ self->mLoginSDKMap setObject:obj forKey:provider];
}

- (void) forPush:(NSString *)provider :(id<IPush>)  obj
{
    [ self->mPushSDKMap setObject:obj forKey:provider];
}

@end


