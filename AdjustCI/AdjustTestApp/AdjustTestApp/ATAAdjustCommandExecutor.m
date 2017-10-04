//
//  ATAAdjustCommandExecutor.m
//  AdjustTestApp
//
//  Created by Pedro on 23.08.17.
//  Copyright © 2017 adjust. All rights reserved.
//

#import "ATAAdjustCommandExecutor.h"
#import "Adjust.h"
#import "ADJAdjustFactory.h"

@interface ATAAdjustCommandExecutor ()

@property (nonatomic, strong) NSMutableDictionary *savedConfigs;
@property (nonatomic, strong) NSMutableDictionary *savedEvents;
@property (nonatomic, copy) NSString *basePath;

@end

@implementation ATAAdjustCommandExecutor

- (id)init {
    self = [super init];
    if (self == nil) return nil;

    self.savedConfigs = [NSMutableDictionary dictionary];
    self.savedEvents = [NSMutableDictionary dictionary];

    return self;
}

- (void)executeCommand:(NSString *)className
            methodName:(NSString *)methodName
            parameters:(NSDictionary *)parameters {

    NSLog(@"executeCommand className: %@, methodName: %@, parameters: %@", className, methodName, parameters);

    if ([methodName isEqualToString:@"factory"]) {
        [self factory:parameters];
    } else if ([methodName isEqualToString:@"config"]) {
        [self config:parameters];
    } else if ([methodName isEqualToString:@"start"]) {
        [self start:parameters];
    } else if ([methodName isEqualToString:@"event"]) {
        [self event:parameters];
    } else if ([methodName isEqualToString:@"trackEvent"]) {
        [self trackEvent:parameters];
    } else if ([methodName isEqualToString:@"resume"]) {
        [self resume:parameters];
    } else if ([methodName isEqualToString:@"pause"]) {
        [self pause:parameters];
    } else if ([methodName isEqualToString:@"setEnabled"]) {
        [self setEnabled:parameters];
    } else if ([methodName isEqualToString:@"setOfflineMode"]) {
        [self setOfflineMode:parameters];
    } else if ([methodName isEqualToString:@"sendFirstPackages"]) {
        [self sendFirstPackages:parameters];
    } else if ([methodName isEqualToString:@"addSessionCallbackParameter"]) {
        [self addSessionCallbackParameter:parameters];
    } else if ([methodName isEqualToString:@"addSessionPartnerParameter"]) {
        [self addSessionPartnerParameter:parameters];
    } else if ([methodName isEqualToString:@"removeSessionCallbackParameter"]) {
        [self removeSessionCallbackParameter:parameters];
    } else if ([methodName isEqualToString:@"removeSessionPartnerParameter"]) {
        [self removeSessionPartnerParameter:parameters];
    } else if ([methodName isEqualToString:@"resetSessionCallbackParameters"]) {
        [self resetSessionCallbackParameters:parameters];
    } else if ([methodName isEqualToString:@"resetSessionPartnerParameters"]) {
        [self resetSessionPartnerParameters:parameters];
    } else if ([methodName isEqualToString:@"setPushToken"]) {
        [self setPushToken:parameters];
    } else if ([methodName isEqualToString:@"teardown"]) {
        [self teardown:parameters];
    } else if ([methodName isEqualToString:@"openDeeplink"]) {
        [self openDeeplink:parameters];
    } else if ([methodName isEqualToString:@"testBegin"]) {
        [self testBegin:parameters];
    } else if ([methodName isEqualToString:@"testEnd"]) {
        [self testEnd:parameters];
    }
}
- (void)factory:(NSDictionary *)parameters {
    if ([parameters objectForKey:@"basePath"]) {
        self.basePath = [parameters objectForKey:@"basePath"][0];
    }
    if ([parameters objectForKey:@"timerInterval"]) {
        NSString *timerIntervalMilliS = [parameters objectForKey:@"timerInterval"][0];
        [ADJAdjustFactory setTimerInterval:[ATAAdjustCommandExecutor convertMilliStringToInterval:timerIntervalMilliS]];
    }
    if ([parameters objectForKey:@"timerStart"]) {
        NSString *timerStartMilliS = [parameters objectForKey:@"timerStart"][0];
        [ADJAdjustFactory setTimerStart:[ATAAdjustCommandExecutor convertMilliStringToInterval:timerStartMilliS]];
    }
    if ([parameters objectForKey:@"sessionInterval"]) {
        NSString *sessionIntervalMilliS = [parameters objectForKey:@"sessionInterval"][0];
        [ADJAdjustFactory setSessionInterval:[ATAAdjustCommandExecutor convertMilliStringToInterval:sessionIntervalMilliS]];
    }
    if ([parameters objectForKey:@"subsessionInterval"]) {
        NSString *subsessionIntervalMilliS = [parameters objectForKey:@"subsessionInterval"][0];
        [ADJAdjustFactory setSubsessionInterval:[ATAAdjustCommandExecutor convertMilliStringToInterval:subsessionIntervalMilliS]];
    }
}

+ (NSTimeInterval)convertMilliStringToInterval:(NSString *)milliS {
    int milli = [milliS intValue];
    double_t sec = milli / 1000;
    return sec;
}

- (void)config:(NSDictionary *)parameters {
    NSNumber *configNumber = [NSNumber numberWithInt:0];

    if ([parameters objectForKey:@"configName"]) {
        NSString *configName = [parameters objectForKey:@"configName"][0];
        NSString *configNumberS = [configName substringFromIndex:[configName length] - 1];
        configNumber = [NSNumber numberWithInt:[configNumberS intValue]];
    }

    ADJConfig *adjustConfig = nil;

    if ([self.savedConfigs objectForKey:configNumber]) {
        adjustConfig = [self.savedConfigs objectForKey:configNumber];
    } else {
        NSString *environment = [parameters objectForKey:@"environment"][0];
        NSString *appToken = [parameters objectForKey:@"appToken"][0];

        adjustConfig = [ADJConfig configWithAppToken:appToken environment:environment];
        [self.savedConfigs setObject:adjustConfig forKey:configNumber];
    }

    if ([parameters objectForKey:@"logLevel"]) {
        NSString *logLevelS = [parameters objectForKey:@"logLevel"][0];
        ADJLogLevel logLevel = [ADJLogger logLevelFromString:logLevelS];
        [adjustConfig setLogLevel:logLevel];
    }

    if ([parameters objectForKey:@"sdkPrefix"]) {
        NSString *sdkPrefix = [parameters objectForKey:@"sdkPrefix"][0];
        [adjustConfig setSdkPrefix:sdkPrefix];
    }

    if ([parameters objectForKey:@"defaultTracker"]) {
        NSString *defaultTracker = [parameters objectForKey:@"defaultTracker"][0];
        [adjustConfig setDefaultTracker:defaultTracker];
    }

    if ([parameters objectForKey:@"appSecret"]) {
        NSArray *appSecretList = [parameters objectForKey:@"appSecret"];
        NSUInteger secretId = [appSecretList[0] integerValue];
        NSUInteger part1 = [appSecretList[1] integerValue];
        NSUInteger part2 = [appSecretList[2] integerValue];
        NSUInteger part3 = [appSecretList[3] integerValue];
        NSUInteger part4 = [appSecretList[4] integerValue];

        [adjustConfig setAppSecret:secretId info1:part1 info2:part2 info3:part3 info4:part4];
    }

    if ([parameters objectForKey:@"delayStart"]) {
        NSString *delayStartS = [parameters objectForKey:@"delayStart"][0];
        double delayStart = [delayStartS doubleValue];
        [adjustConfig setDelayStart:delayStart];
    }

    if ([parameters objectForKey:@"deviceKnown"]) {
        NSString *deviceKnownS = [parameters objectForKey:@"deviceKnown"][0];
        [adjustConfig setIsDeviceKnown:[deviceKnownS boolValue]];
    }

    if ([parameters objectForKey:@"eventBufferingEnabled"]) {
        NSString *eventBufferingEnabledS = [parameters objectForKey:@"eventBufferingEnabled"][0];
        [adjustConfig setEventBufferingEnabled:[eventBufferingEnabledS boolValue]];
    }

    if ([parameters objectForKey:@"sendInBackground"]) {
        NSString *sendInBackgroundS = [parameters objectForKey:@"sendInBackground"][0];
        [adjustConfig setSendInBackground:[sendInBackgroundS boolValue]];
    }

    if ([parameters objectForKey:@"userAgent"]) {
        NSString *userAgent = [parameters objectForKey:@"userAgent"][0];
        [adjustConfig setUserAgent:userAgent];
    }
}

- (void)start:(NSDictionary *)parameters {
    [self config:parameters];

    NSNumber *configNumber = [NSNumber numberWithInt:0];

    if ([parameters objectForKey:@"configName"]) {
        NSString *configName = [parameters objectForKey:@"configName"][0];
        NSString *configNumberS = [configName substringFromIndex:[configName length] - 1];
        configNumber = [NSNumber numberWithInt:[configNumberS intValue]];
    }

    ADJConfig *adjustConfig = [self.savedConfigs objectForKey:configNumber];

    [adjustConfig setBasePath:self.basePath];

    [Adjust appDidLaunch:adjustConfig];

    [self.savedConfigs removeObjectForKey:[NSNumber numberWithInt:0]];
}

- (void)event:(NSDictionary *)parameters {
    NSNumber *eventNumber = [NSNumber numberWithInt:0];

    if ([parameters objectForKey:@"eventName"]) {
        NSString *eventName = [parameters objectForKey:@"eventName"][0];
        NSString *eventNumberS = [eventName substringFromIndex:[eventName length] - 1];
        eventNumber = [NSNumber numberWithInt:[eventNumberS intValue]];
    }

    ADJEvent *adjustEvent = nil;

    if ([self.savedEvents objectForKey:eventNumber]) {
        adjustEvent = [self.savedEvents objectForKey:eventNumber];
    } else {
        NSString *eventToken = [parameters objectForKey:@"eventToken"][0];

        adjustEvent = [ADJEvent eventWithEventToken:eventToken];
        [self.savedEvents setObject:adjustEvent forKey:eventNumber];
    }

    if ([parameters objectForKey:@"revenue"]) {
        NSArray *currencyAndRevenue = [parameters objectForKey:@"revenue"];
        NSString *currency = currencyAndRevenue[0];
        double revenue = [currencyAndRevenue[1] doubleValue];

        [adjustEvent setRevenue:revenue currency:currency];
    }

    if ([parameters objectForKey:@"callbackParams"]) {
        NSArray *callbackParams = [parameters objectForKey:@"callbackParams"];
        for (int i = 0; i < callbackParams.count; i = i + 2) {
            NSString *key = callbackParams[i];
            NSString *value = callbackParams[i + 1];
            [adjustEvent addCallbackParameter:key value:value];
        }
    }

    if ([parameters objectForKey:@"partnerParams"]) {
        NSArray *partnerParams = [parameters objectForKey:@"partnerParams"];
        for (int i = 0; i < partnerParams.count; i = i + 2) {
            NSString *key = partnerParams[i];
            NSString *value = partnerParams[i + 1];
            [adjustEvent addPartnerParameter:key value:value];
        }
    }

    if ([parameters objectForKey:@"orderId"]) {
        NSString *transactionId = [parameters objectForKey:@"orderId"][0];
        [adjustEvent setTransactionId:transactionId];
    }
}

- (void)trackEvent:(NSDictionary *)parameters {
    [self event:parameters];

    NSNumber *eventNumber = [NSNumber numberWithInt:0];

    if ([parameters objectForKey:@"eventName"]) {
        NSString *eventName = [parameters objectForKey:@"eventName"][0];
        NSString *eventNumberS = [eventName substringFromIndex:[eventName length] - 1];
        eventNumber = [NSNumber numberWithInt:[eventNumberS intValue]];
    }

    ADJEvent *adjustEvent = [self.savedEvents objectForKey:eventNumber];

    [Adjust trackEvent:adjustEvent];

    [self.savedEvents removeObjectForKey:[NSNumber numberWithInt:0]];
}

- (void)resume:(NSDictionary *)parameters {
    [Adjust trackSubsessionStart];
}

- (void)pause:(NSDictionary *)parameters {
    [Adjust trackSubsessionEnd];
}

- (void)setEnabled:(NSDictionary *)parameters {
    NSString *enabledS = [parameters objectForKey:@"enabled"][0];
    [Adjust setEnabled:[enabledS boolValue]];
}

- (void)setOfflineMode:(NSDictionary *)parameters {
    NSString *enabledS = [parameters objectForKey:@"enabled"][0];
    [Adjust setOfflineMode:[enabledS boolValue]];
}

- (void)sendFirstPackages:(NSDictionary *)parameters {
    [Adjust sendFirstPackages];
}

- (void)addSessionCallbackParameter:(NSDictionary *)parameters {
    NSArray *keyValuesPairs = [parameters objectForKey:@"KeyValue"];
    for (int i = 0; i < keyValuesPairs.count; i = i + 2) {
        NSString *key = keyValuesPairs[i];
        NSString *value = keyValuesPairs[i + 1];
        [Adjust addSessionCallbackParameter:key value:value];
    }
}

- (void)addSessionPartnerParameter:(NSDictionary *)parameters {
    NSArray *keyValuesPairs = [parameters objectForKey:@"KeyValue"];
    for (int i = 0; i < keyValuesPairs.count; i = i + 2) {
        NSString *key = keyValuesPairs[i];
        NSString *value = keyValuesPairs[i + 1];
        [Adjust addSessionPartnerParameter:key value:value];
    }
}

- (void)removeSessionCallbackParameter:(NSDictionary *)parameters {
    NSArray *keys = [parameters objectForKey:@"key"];
    for (int i = 0; i < keys.count; i = i + 1) {
        NSString *key = keys[i];
        [Adjust removeSessionCallbackParameter:key];
    }
}

- (void)removeSessionPartnerParameter:(NSDictionary *)parameters {
    NSArray *keys = [parameters objectForKey:@"key"];
    for (int i = 0; i < keys.count; i = i + 1) {
        NSString *key = keys[i];
        [Adjust removeSessionPartnerParameter:key];
    }
}

- (void)resetSessionCallbackParameters:(NSDictionary *)parameters {
    [Adjust resetSessionCallbackParameters];
}

- (void)resetSessionPartnerParameters:(NSDictionary *)parameters {
    [Adjust resetSessionPartnerParameters];
}

- (void)setPushToken:(NSDictionary *)parameters {
    NSString *deviceTokenS = [parameters objectForKey:@"pushToken"][0];
    NSData *deviceToken = [deviceTokenS dataUsingEncoding:NSUTF8StringEncoding];
    [Adjust setDeviceToken:deviceToken];
}

- (void)teardown:(NSDictionary *)parameters {
    NSString *deleteStateS = [parameters objectForKey:@"deleteState"][0];
    BOOL deleteState = [deleteStateS boolValue];
    [Adjust teardown:deleteState];
}

- (void)openDeeplink:(NSDictionary *)parameters {
    NSString *deeplinkS = [parameters objectForKey:@"deeplink"][0];
    NSURL *deeplink = [NSURL URLWithString:deeplinkS];
    [Adjust appWillOpenUrl:deeplink];
}

- (void)testBegin:(NSDictionary *)parameters {
    NSLog(@"testBegin parameters: %@", parameters);

    if ([parameters objectForKey:@"basePath"]) {
        self.basePath = [parameters objectForKey:@"basePath"][0];
    }

    [ADJAdjustFactory teardown:YES];
    self.savedConfigs = [NSMutableDictionary dictionary];
    self.savedEvents = [NSMutableDictionary dictionary];
}

- (void)testEnd:(NSDictionary *)parameters {
    [ADJAdjustFactory teardown:YES];
}
@end
