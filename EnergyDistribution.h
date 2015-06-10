//
//  EnergyDistribution.h
//  EnergyBreakapp
//
//  Created by Class Account on 10/31/13.
//  Copyright (c) 2013 UC Berkeley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EnergyDistribution : NSObject <NSURLConnectionDelegate>
{
    int zipCode;
}

@property double coalPercentage, oilPercentage, gasPercentage, nuclearPercentage, hydroPercentage, renewablePercentage, otherPercentage, biomassPercentage, biogasPercentage, windPercentage, solarPercentage, geothermalPercentage;
@property (nonatomic, strong) NSMutableData *responseData;
@property NSString *token;

-(id) initWithLatLon:(double) lat :(double) lon;
-(id) initWithZipCode:(int) currentZipCode;
-(double) totalPercentages;

@end
