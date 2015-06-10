//
//  EnergyDataGetter.m
//  EnergyBreakapp
//
//  Created by Class Account on 10/24/13.
//  Copyright (c) 2013 UC Berkeley. All rights reserved.
//

#import "EnergyDataGetter.h"

@implementation EnergyDataGetter

-(id) init: (NSString*) ZIPCode
{
    self = [super init];
    if (self) {
        request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.google.com"]];
        /*request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://oaspub.epa.gov/powpro/ept_pack.utility"]];
        [request setHTTPMethod:@"POST"];
        [request setValue:ZIPCode forHTTPHeaderField:@"zip-code"];
        [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];*/
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        NSLog(@"Connection started");
    }
    return self;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    NSLog(@"Received response");
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    NSLog(@"Data received");
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    NSLog(@"Finished loading");
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    NSLog(@"Connection failed");
}


@end
