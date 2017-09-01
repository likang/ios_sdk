//
//  AdjustTestLibrary.m
//  AdjustTestLibrary
//
//  Created by Pedro on 18.04.17.
//  Copyright © 2017 adjust. All rights reserved.
//

#import "ATLTestLibrary.h"
#import "ATLUtil.h"
#import "ATLConstants.h"
#import "ATLControlChannel.h"

//static const char * const kInternalQueueName     = "com.adjust.TestLibrary";

@interface ATLTestLibrary()

@property (nonatomic, weak, nullable) NSObject<AdjustCommandDelegate> *commandDelegate;
//@property (nonatomic, strong) dispatch_queue_t internalQueue;
@property (nonatomic, strong) NSOperationQueue* operationQueue;

@property (nonatomic, copy) NSString *currentBasePath;
//@property (nonatomic, copy) NSString *baseUrl;
@property (nonatomic, strong) MKBlockingQueue *waitControlQueue;
@property (nonatomic, strong) ATLControlChannel *controlChannel;
@property (nonatomic, copy) NSString *testNames;

@end

@implementation ATLTestLibrary

static NSURL * _baseUrl = nil;

+ (NSURL *)baseUrl {
    return _baseUrl;
}

+ (ATLTestLibrary *)testLibraryWithBaseUrl:(NSString *)baseUrl
                        andCommandDelegate:(NSObject<AdjustCommandDelegate> *)commandDelegate {
    return [[ATLTestLibrary alloc] initWithBaseUrl:baseUrl
                                andCommandDelegate:commandDelegate];
}
- (id)initWithBaseUrl:(NSString *)baseUrl
   andCommandDelegate:(NSObject<AdjustCommandDelegate> *)commandDelegate;
{
    self = [super init];
    if (self == nil) return nil;
    
    _baseUrl = [NSURL URLWithString:baseUrl];
    //self.baseUrl = baseUrl;
    self.commandDelegate = commandDelegate;
    
    return self;
}

- (void)setTests:(NSString *)testNames {
    self.testNames = testNames;
}

- (void)startTestSession:(NSString *)clientSdk {
    [self resetTestLibrary];

    [ATLUtil addOperationAfterLast:self.operationQueue
                             block:^{
                                 [self sendTestSessionI:clientSdk];
                             }];
/*
    [ATLUtil launchInQueue:self.internalQueue
                 selfInject:self
                      block:^(ATLTestLibrary * selfI) {
                          [selfI sendTestSessionI:clientSdk];
                      }];
*/
}

- (void)resetTestLibrary {
    [self teardown];

    [self initTestLibrary];
}

- (void)teardown {
    if (self.operationQueue != nil) {
        [ATLUtil debug:@"cancel test library thread queue"];
        [self.operationQueue cancelAllOperations];
    }
    self.operationQueue = nil;

    [self clearTest];
}

- (void)clearTest {
    if (self.controlChannel != nil) {
        [self.controlChannel teardown];
    }
    self.waitControlQueue = nil;
    self.controlChannel = nil;
}

- (void) initTestLibrary {
    self.waitControlQueue = [[MKBlockingQueue alloc] init];

    self.operationQueue = [[NSOperationQueue alloc] init];
    [self.operationQueue setMaxConcurrentOperationCount:1];
}

- (void)resetTest {
    [self clearTest];

    [self initTest];
}

- (void)initTest {
    self.waitControlQueue = [[MKBlockingQueue alloc] init];
    self.controlChannel = [[ATLControlChannel alloc] initWithTestLibrary:self];
}

- (void)sendTestSessionI:(NSString *)clientSdk {
    ATLHttpRequest * requestData = [[ATLHttpRequest alloc] init];

    NSMutableDictionary * headerFields = [NSMutableDictionary dictionaryWithObjectsAndKeys:clientSdk, @"Client-SDK", nil];

    if (self.testNames != nil) {
        [headerFields setObject:self.testNames forKey:@"Test-Names"];
    }

    requestData.headerFields = headerFields;
    requestData.path = @"/init_session";
    
    [ATLUtilNetworking sendPostRequest:requestData
                        responseHandler:^(ATLHttpResponse *httpResponse) {
                            [self readHeaders:httpResponse];
                        }];
}

- (void)readHeaders:(ATLHttpResponse *)httpResponse {
    [ATLUtil addOperationAfterLast:self.operationQueue
                             block:^{
                                 [self readHeadersI:httpResponse];
                             }];
    /*
    [ATLUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ATLTestLibrary * selfI) {
                         [selfI readHeadersI:httpResponse];
                     }];
     */
}
- (void)readHeadersI:(ATLHttpResponse *)httpResponse {
    if (httpResponse.headerFields == nil) {
        [ATLUtil debug:@"headers null"];
        return;
    }
    
    if ([httpResponse.headerFields objectForKey:TEST_SESSION_END_HEADER]) {
        [self teardown];
        [ATLUtil debug:@"TestSessionEnd received"];
        return;
    }
    if ([httpResponse.headerFields objectForKey:BASE_PATH_HEADER]) {
        self.currentBasePath = httpResponse.headerFields[BASE_PATH_HEADER];
    }
    if ([httpResponse.headerFields objectForKey:TEST_SCRIPT_HEADER]) {
        NSString * currentTest = httpResponse.headerFields[TEST_SCRIPT_HEADER];
        [ATLUtil debug:@"current test is %@", currentTest];

        [self resetTest];

        //[self execTestCommandsI:httpResponse.jsonResponse];
        [self execTestCommandsI:httpResponse.jsonFoundation];
    }
}

- (void)execTestCommandsI:(id)jsonFoundation {
    NSArray * jsonArray = (NSArray *)jsonFoundation;
    if (jsonArray == nil) {
        [ATLUtil debug:@"jsonArray is nil"];
        return;
    }

    for (NSDictionary * testCommand in jsonArray) {
        NSString * className = [testCommand objectForKey:@"className"];
        NSString * functionName = [testCommand objectForKey:@"functionName"];
        NSDictionary * params = [testCommand objectForKey:@"params"];
        [ATLUtil debug:@"className: %@, functionName: %@, params: %@", className, functionName, params];

        NSDate *timeBefore = [NSDate date];
        [ATLUtil debug:@"time before %@", [ATLUtil formatDate:timeBefore]];

        // check for test library commands
        if ([className isEqualToString:TEST_LIBRARY_CLASSNAME]) {
            [self execTestLibraryCommandI:functionName params:params];

            NSDate *timeAfter = [NSDate date];
            [ATLUtil debug:@"time after %@", [ATLUtil formatDate:timeAfter]];
            NSTimeInterval timeElapsedSeconds = [timeAfter timeIntervalSinceDate:timeBefore];
            [ATLUtil debug:@"seconds elapsed %f", timeElapsedSeconds];

            continue;
        }

        if (![className isEqualToString:ADJUST_CLASSNAME]) {
            [ATLUtil debug:@"className %@ is not valid", className];
            continue;
        }

        if ([self.commandDelegate respondsToSelector:@selector(executeCommand:methodName:parameters:)]) {
            [self.commandDelegate executeCommand:className methodName:functionName parameters:params];
        } else if ([self.commandDelegate respondsToSelector:@selector(executeCommand:methodName:jsonParameters:)]) {

            NSString *paramsJsonString = [ATLUtil parseDictionaryToJsonString:params];

            [self.commandDelegate executeCommand:className methodName:functionName jsonParameters:paramsJsonString];
        }

        NSDate *timeAfter = [NSDate date];
        [ATLUtil debug:@"time after %@", [ATLUtil formatDate:timeAfter]];
        NSTimeInterval timeElapsedSeconds = [timeAfter timeIntervalSinceDate:timeBefore];
        [ATLUtil debug:@"seconds elapsed %f", timeElapsedSeconds];
    }
}

- (void)execTestLibraryCommandI:(NSString *)functionName
                         params:(NSDictionary *)params {
    if ([functionName isEqualToString:@"end_test"]) {
        [self endTestI:params];
    } else if ([functionName isEqualToString:@"wait"]) {
        [self waitI:params];
    }
}

- (void)endTestI:(NSDictionary *)params {
    ATLHttpRequest * requestData = [[ATLHttpRequest alloc] init];
    requestData.path = [ATLUtilNetworking appendBasePath:self.currentBasePath path:@"/end_test"];

    [ATLUtilNetworking sendPostRequest:requestData
                       responseHandler:^(ATLHttpResponse *httpResponse) {
                           [self readHeaders:httpResponse];
                       }];
}

- (void)waitI:(NSDictionary *)params {
    if ([params objectForKey:WAIT_FOR_CONTROL]) {
        NSString * waitExpectedReason = [params objectForKey:WAIT_FOR_CONTROL][0];
        [ATLUtil debug:@"wait for %@", waitExpectedReason];
        NSString * endReason = [self.waitControlQueue dequeue];
        [ATLUtil debug:@"wait ended due to %@", endReason];
    }

    if ([params objectForKey:WAIT_FOR_SLEEP]) {
        NSString * millisToSleepS = [params objectForKey:WAIT_FOR_SLEEP][0];
        [ATLUtil debug:@"sleep for %@", millisToSleepS];

        double secondsToSleep = [millisToSleepS intValue] / 1000;
        [NSThread sleepForTimeInterval:secondsToSleep];

        [ATLUtil debug:@"sleep ended"];
    }
}
@end
