//
//  AdjustTestLibrary.h
//  AdjustTestLibrary
//
//  Created by Pedro on 18.04.17.
//  Copyright © 2017 adjust. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATLUtilNetworking.h"
#import "MKBlockingQueue.h"

@protocol AdjustCommandDelegate <NSObject>
@optional
- (void)executeCommand:(NSString *)className
            methodName:(NSString *)methodName
            parameters:(NSDictionary *)parameters;

- (void)executeCommand:(NSString *)className
            methodName:(NSString *)methodName
        jsonParameters:(NSString *)jsonParameters;
@end

@interface ATLTestLibrary : NSObject

- (id)initWithBaseUrl:(NSString *)baseUrl
   andCommandDelegate:(NSObject<AdjustCommandDelegate> *)commandDelegate;

- (void)setTests:(NSString *)testNames;

- (void)startTestSession:(NSString *)clientSdk;

- (NSString *)currentBasePath;
- (MKBlockingQueue *)waitControlQueue;

- (void)resetTestLibrary;

- (void)readHeaders:(ATLHttpResponse *)httpResponse;

+ (ATLTestLibrary *)testLibraryWithBaseUrl:(NSString *)baseUrl
andCommandDelegate:(NSObject<AdjustCommandDelegate> *)commandDelegate;

+ (NSURL *)baseUrl;
@end
