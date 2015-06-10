//
//  EnergyDataGetter.h
//  EnergyBreakapp
//
//  Created by Class Account on 10/24/13.
//  Copyright (c) 2013 UC Berkeley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EnergyDataGetter : NSObject <NSURLConnectionDelegate>
{
    NSMutableURLRequest *request;
    NSMutableData *_responseData;
}

-(id) init: (NSString*) ZIPCode;

@end
