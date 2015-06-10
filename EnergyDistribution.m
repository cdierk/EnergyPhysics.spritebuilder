//
//  EnergyDistribution.m
//  EnergyBreakapp
//
//  Created by Class Account on 10/31/13.
//  Copyright (c) 2013 UC Berkeley. All rights reserved.
//

#import "EnergyDistribution.h"

@implementation EnergyDistribution

@synthesize coalPercentage, gasPercentage, oilPercentage, hydroPercentage, nuclearPercentage, renewablePercentage, otherPercentage, biomassPercentage, biogasPercentage, windPercentage, solarPercentage, geothermalPercentage, token;


/* Sets the values of the percentages of each energy source using latitude and longitude
 and the WattTime API */
-(id)initWithLatLon:(double)lat :(double)lon
{
    self = [super init];
    token = @"ccc1ef70db856e20abbaa3851b1cb1505c61131b";
    otherPercentage = 0.0;
    coalPercentage = 0.0;
    oilPercentage = 0.0;
    gasPercentage = 0.0;
    nuclearPercentage = 0.0;
    hydroPercentage = 0.0;
    renewablePercentage = 0.0;
    biomassPercentage = 0.0;
    windPercentage = 0.0;
    solarPercentage = 0.0;
    geothermalPercentage = 0.0;
    biogasPercentage = 0.0;
    __block double coalGeneration = 0, oilGeneration = 0, gasGeneration = 0, nuclearGeneration = 0, hydroGeneration = 0, renewableGeneration = 0, otherGeneration = 0, biomassGeneration = 0, biogasGeneration = 0, windGeneration = 0, solarGeneration = 0, geothermalGeneration = 0, totalGeneration = 0;
    
    /* Making a synchronous request to first get the correct balancing authority,
     then to find the energy mix for that authority.
     This code currently does not use an API authentication token, but this will need to be added
     to make more than 25 requests/hour to the API. Instructions on how to use the token can be
     found after registering at:
     http://watttime-grid-api.herokuapp.com/accounts/register/*/
     
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //make sure there is no / at the end of url
        NSString *urlString = [NSString stringWithFormat: @"http://api.watttime.org/api/v1/balancing_authorities/?loc=POINT(%f %f)", lon, lat];
        urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"The URL is %@", urlString);
                                           
        NSURL *url = [NSURL URLWithString:(urlString)];
        
        //added Authorization code
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:30.0];
        [request addValue:[NSString stringWithFormat:@"OAuth %@", token] forHTTPHeaderField:@"Authorization"];
        [request setHTTPMethod:@"GET"];
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error: &error];

        
        //NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        NSArray* json = nil;
        if (data) {
            json = [NSJSONSerialization
                    JSONObjectWithData:data
                    options:kNilOptions
                    error:nil];
        }
        
        NSLog(@"%@", json);
        
        NSString *baAbbrev = [json[0] objectForKey:@"abbrev"];
        if (baAbbrev == NULL) baAbbrev = @"CAISO";              //cheating
        
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //again, make sure there is no slash at the end of url
            NSString *urlString2 = [NSString stringWithFormat: @"http://api.watttime.org/api/v1/datapoints/?ba=%@&market=RT5M", baAbbrev];
            urlString2 = [urlString2 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSLog(@"The URL is %@", urlString2);
            
            NSURL *url2 = [NSURL URLWithString:urlString2];
            
            //added Authorization code
            NSMutableURLRequest *request2 = [NSMutableURLRequest requestWithURL:url2
                                                                   cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                               timeoutInterval:30.0];
            [request addValue:[NSString stringWithFormat:@"OAuth %@", token] forHTTPHeaderField:@"Authorization"];
            [request setHTTPMethod:@"GET"];
            NSError *error2 = nil;
            NSData *data = [NSURLConnection sendSynchronousRequest:request2 returningResponse:nil error: &error2];

            
            //NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url2]];
            NSDictionary* json = nil;
            if (data) {
                json = [NSJSONSerialization
                        JSONObjectWithData:data
                        options:kNilOptions
                        error:nil];
            }
            
            NSLog(@"%@", json);
            
            NSArray *arrayOfFuels = json[@"results"][0][@"genmix"];
            for (NSDictionary *dict in arrayOfFuels) {
                NSString *fuelType = [dict objectForKey:@"fuel"];
                NSLog(@"%@", fuelType);
                if ([fuelType  isEqual: @"biomass"]) {
                    biomassGeneration = [[dict objectForKey:@"gen_MW"] doubleValue];
                    totalGeneration += biomassGeneration;
                }
                /*We are currently not displaying the contribution of biogas. Uncomment the code below
                 to add biogas to the total fuel generation.
                 To display it, edit fillBattery in BatteryView.m to additionally fill in the battery
                 for biogas.
                 Don't forget to additionally change to storyboard so that the key contains the colour
                 and corresponding label for biogas.*/
                
                /*
                else if ([fuelType  isEqual: @"biogas"]){
                    biogasGeneration = [[dict objectForKey:@"gen_MW"] doubleValue];
                    totalGeneration += biogasGeneration;
                }
                */
                
                else if ([fuelType  isEqual: @"coal"]) {
                    coalGeneration = [[dict objectForKey:@"gen_MW"] doubleValue];
                    totalGeneration += coalGeneration;
                }
                else if ([fuelType  isEqual: @"geo"]) {
                    geothermalGeneration = [[dict objectForKey:@"gen_MW"] doubleValue];
                    totalGeneration += geothermalGeneration;
                }
                else if ([fuelType  isEqual: @"hydro"]) {
                    hydroGeneration = [[dict objectForKey:@"gen_MW"] doubleValue];
                    totalGeneration += hydroGeneration;
                }
                else if ([fuelType  isEqual: @"natgas"]) {
                    gasGeneration = [[dict objectForKey:@"gen_MW"] doubleValue];
                    totalGeneration += gasGeneration;
                }
                else if ([fuelType  isEqual: @"nuclear"]) {
                    nuclearGeneration = [[dict objectForKey:@"gen_MW"] doubleValue];
                    totalGeneration += nuclearGeneration;
                }
                else if ([fuelType  isEqual: @"oil"]) {
                    oilGeneration = [[dict objectForKey:@"gen_MW"] doubleValue];
                    totalGeneration += oilGeneration;
                }
                else if ([fuelType  isEqual: @"solar"]) {
                    solarGeneration = [[dict objectForKey:@"gen_MW"] doubleValue];
                    totalGeneration += solarGeneration;
                }
                else if ([fuelType  isEqual: @"wind"]) {
                    windGeneration = [[dict objectForKey:@"gen_MW"] doubleValue];
                    totalGeneration += windGeneration;
                }
                else if ([fuelType  isEqual: @"other"]) {
                    otherGeneration = [[dict objectForKey:@"gen_MW"] doubleValue];
                    totalGeneration += otherGeneration;
                }
            }
            
        });
        coalPercentage = coalGeneration/totalGeneration;
        oilPercentage = oilGeneration/totalGeneration;
        gasPercentage = gasGeneration/totalGeneration;
        nuclearPercentage = nuclearGeneration/totalGeneration;
        hydroPercentage = hydroGeneration/totalGeneration;
        biomassPercentage = biomassGeneration/totalGeneration;
        biogasPercentage = biogasGeneration/totalGeneration;
        windPercentage = windGeneration/totalGeneration;
        solarPercentage = solarGeneration/totalGeneration;
        geothermalPercentage = geothermalGeneration/totalGeneration;
        otherPercentage = otherGeneration/totalGeneration;
        NSLog(@"coal percentage is %f", coalPercentage);
        NSLog(@"oil percentage is %f", oilPercentage);
        NSLog(@"gas percentage is %f", gasPercentage);
        NSLog(@"nuclear percentage is %f", nuclearPercentage);
        NSLog(@"biomass percentage is %f", biomassPercentage);
        NSLog(@"biogas percentage is %f", biogasPercentage);
        NSLog(@"geothermal percentage is %f", geothermalPercentage);
        NSLog(@"solar percentage is %f", solarPercentage);
        NSLog(@"hydro percentage is %f", hydroPercentage);
        NSLog(@"other percentage is %f", otherPercentage);
    });
    return self;
}

-(id)initWithZipCode:(int)currentZipCode
{
    NSLog(@"Zip code inputted is %i", currentZipCode);
    self = [super init];
    if (self) {
        zipCode = currentZipCode;
        otherPercentage = 0.0;
        [self setPercentages];
    }
    return self;
}

-(void)setPercentages
{
    //AKGD
    if ((zipCode >= 99501 && zipCode <= 99540) || (zipCode == 198) || (zipCode == 6)){
        coalPercentage = 11.8133;
        oilPercentage = 13.6743;
        gasPercentage = 66.0333;
        nuclearPercentage = 0.0;
        hydroPercentage = 8.4791;
        renewablePercentage = 0.0;
        biomassPercentage = 0.0;
        windPercentage = 0.0;
        solarPercentage = 0.0;
        geothermalPercentage = 0.0;
    }
    //AKMS
    else if ((zipCode >= 99545 && zipCode <= 99950) || (zipCode == 2) || (zipCode == 7) || (zipCode == 10) || (zipCode == 11)){
        renewablePercentage = 0.9924;
        coalPercentage = 0.0;
        oilPercentage = 31.2972;
        gasPercentage = 3.8526;
        nuclearPercentage = 0.0;
        hydroPercentage = 63.8578;
        biomassPercentage = 0.4773;
        windPercentage = 0.5151;
        solarPercentage = 0.0;
        geothermalPercentage = 0.0;
    }
    //AZNM
    else if ((zipCode >= 88268 && zipCode <= 89199) ||
             (zipCode >= 85001 && zipCode <= 88081) ||
             (zipCode >= 79901 && zipCode <= 79999) ||
             (zipCode == 197) ||
             (zipCode == 199) ||
             (zipCode == 64) ||
             (zipCode == 66) ||
             (zipCode == 14) ||
             (zipCode == 15))
    {
        coalPercentage = 38.5979;
        oilPercentage = 0.0598;
        gasPercentage = 35.6808;
        nuclearPercentage = 16.4726;
        hydroPercentage = 6.0901;
        renewablePercentage = 3.0976;
        biomassPercentage = 0.3166;
        windPercentage = 0.5008;
        solarPercentage = 0.1012;
        geothermalPercentage = 2.1789;
    }
    //CAMX
    else if ((zipCode >= 90001 && zipCode <= 96093) ||
             (zipCode >= 16 && zipCode <= 26) ||
             (zipCode >= 28 && zipCode <= 32) ||
             (zipCode == 65) ||
             (zipCode == 58) ||
             (zipCode == 55) ||
             (zipCode == 54) ||
             (zipCode == 52) ||
             (zipCode == 51) ||
             (zipCode == 50) ||
             (zipCode == 48) ||
             (zipCode == 47) ||
             (zipCode == 44) ||
             (zipCode == 40) ||
             (zipCode == 39) ||
             (zipCode == 38) ||
             (zipCode == 37) ||
             (zipCode == 12))
    {
        coalPercentage = 7.3284;
        oilPercentage = 1.3637;
        gasPercentage = 53.0498;
        nuclearPercentage = 14.9288;
        hydroPercentage = 12.7172;
        renewablePercentage = 10.1482;
        biomassPercentage = 2.7167;
        windPercentage = 2.7635;
        solarPercentage = 0.3003;
        geothermalPercentage = 4.3676;
    }
    //ERCT
    else if ((zipCode >= 79501 && zipCode <= 79855) ||
             (zipCode >= 77801 && zipCode <= 78963) ||
             (zipCode >= 75701 && zipCode <= 77592) ||
             (zipCode >= 75001 && zipCode <= 75550) ||
             (zipCode == 188))
    {
        coalPercentage = 32.9816;
        oilPercentage = 1.0518;
        gasPercentage = 47.8308;
        nuclearPercentage = 12.3127;
        hydroPercentage = 0.1539;
        renewablePercentage = 4.4528;
        biomassPercentage = 0.1215;
        windPercentage = 5.3314;
        solarPercentage = 0.0;
        geothermalPercentage = 0.0;
    }
    //FRCC
    else if ((zipCode >= 32601 && zipCode <= 34997) ||
             (zipCode >= 32003 && zipCode <= 32399) ||
             (zipCode == 87) ||
             (zipCode == 97) ||
             (zipCode == 98) ||
             (zipCode == 41) ||
             (zipCode == 42) ||
             (zipCode == 43) ||
             (zipCode == 45) ||
             (zipCode == 53))
    {
        coalPercentage = 23.6531;
        oilPercentage = 4.4222;
        gasPercentage = 54.8319;
        nuclearPercentage = 13.9907;
        hydroPercentage = 0.0099;
        renewablePercentage = 1.7444;
        biomassPercentage = 1.7398;
        windPercentage = 0.0;
        solarPercentage = 0.0046;
        geothermalPercentage = 0.0;
    }
    //HIMS
    else if ((zipCode >= 96701 && zipCode <=96785))
    {
        coalPercentage = 1.9907;
        oilPercentage = 69.8707;
        gasPercentage = 0.0;
        nuclearPercentage = 0.0;
        hydroPercentage = 3.7312;
        renewablePercentage = 17.2729;
        otherPercentage = 7.1345;
        biomassPercentage = 3.3481;
        windPercentage = 8.3278;
        solarPercentage = 0.0460;
        geothermalPercentage = 5.5510;
    }
    //HIOA
    else if ((zipCode >= 96786 && zipCode <=96898))
    {
        coalPercentage = 18.0201;
        oilPercentage = 77.6079;
        gasPercentage = 0.0;
        nuclearPercentage = 0.0;
        hydroPercentage = 0.0;
        renewablePercentage = 2.1615;
        otherPercentage = 2.2104;
        biomassPercentage = 2.1615;
        windPercentage = 0.0;
        solarPercentage = 0.0;
        geothermalPercentage = 0.0;
    }
    //MROE
    else if ((zipCode >= 54901 && zipCode <= 54990) ||
             (zipCode >= 53501 && zipCode <= 54404) ||
             (zipCode >= 49805 && zipCode <= 49971))
    {
        coalPercentage = 68.9039;
        oilPercentage = 2.3652;
        gasPercentage = 4.9759;
        nuclearPercentage = 15.2608;
        hydroPercentage = 2.7096;
        renewablePercentage = 5.5609;
        biomassPercentage = 3.2381;
        windPercentage = 2.3228;
        solarPercentage = 0.0;
        geothermalPercentage = 0.0;
    }
    //MROW
    else if ((zipCode >= 68001 && zipCode <= 69120) ||
             (zipCode >= 61201 && zipCode <= 61299) ||
             (zipCode >= 55001 && zipCode <= 58843) ||
             (zipCode >= 54405 && zipCode <= 54896) ||
             (zipCode >= 50001 && zipCode <= 52809) ||
             (zipCode >= 160 && zipCode <= 166) ||
             (zipCode == 59)||
             (zipCode == 60))
    {
        coalPercentage = 69.0860;
        oilPercentage = 0.1515;
        gasPercentage = 2.3997;
        nuclearPercentage = 13.9045;
        hydroPercentage = 4.3578;
        renewablePercentage = 9.8491;
        biomassPercentage = 1.1844;
        windPercentage = 8.6647;
        solarPercentage = 0.0;
        geothermalPercentage = 0.0;
    }
    //NEWE
    else if ((zipCode >= 1001 && zipCode <= 6928) ||
             (zipCode >= 168 && zipCode <= 185) ||
             (zipCode >= 127 && zipCode <= 151) ||
             (zipCode == 158))
    {
        coalPercentage = 11.8606;
        oilPercentage = 1.5048;
        gasPercentage = 41.9731;
        nuclearPercentage = 29.7601;
        hydroPercentage = 7.0413;
        renewablePercentage = 6.2269;
        biomassPercentage = 5.9158;
        windPercentage = 0.3110;
        solarPercentage = 0.0;
        geothermalPercentage = 0.0;
    }
    //NWPP
    else if ((zipCode >= 97001 && zipCode <= 99403) ||
             (zipCode >= 96094 && zipCode <= 96162) ||
             (zipCode >= 89301 && zipCode <= 89883) ||
             (zipCode >= 82901 && zipCode <= 84791) ||
             (zipCode >= 58844 && zipCode <= 59937) ||
             (zipCode >= 68 && zipCode <= 77) ||
             (zipCode == 195) ||
             (zipCode == 100) ||
             (zipCode == 33) ||
             (zipCode == 34) ||
             (zipCode == 35) ||
             (zipCode == 56) ||
             (zipCode == 63) ||
             (zipCode == 49))
    {
        coalPercentage = 29.8340;
        oilPercentage = 0.3352;
        gasPercentage = 15.1503;
        nuclearPercentage = 2.4632;
        hydroPercentage = 46.5021;
        renewablePercentage = 5.4491;
        biomassPercentage = 1.0927;
        windPercentage = 3.8023;
        solarPercentage = 0.0;
        geothermalPercentage = 0.5541;
    }
    //NYCW
    else if ((zipCode >= 10001 && zipCode <= 11499))
    {
        coalPercentage = 0.0;
        oilPercentage = 1.7896;
        gasPercentage = 55.8586;
        nuclearPercentage = 40.8410;
        hydroPercentage = 0.0185;
        renewablePercentage = 1.0141;
        biomassPercentage = 0.5357;
        windPercentage = 0.4784;
        solarPercentage = 0.0;
        geothermalPercentage = 0.0;
    }
    //NYLI
    else if ((zipCode >= 11501 && zipCode <= 11980) ||
             (zipCode == 501) ||
             (zipCode == 544))
    {
        coalPercentage = 0.0;
        oilPercentage = 12.9940;
        gasPercentage = 77.3406;
        nuclearPercentage = 0.0;
        hydroPercentage = 0.0;
        renewablePercentage = 5.1108;
        biomassPercentage = 5.1108;
        windPercentage = 0.0;
        solarPercentage = 0.0;
        geothermalPercentage = 0.0;
    }
    //NYUP
    else if ((zipCode >= 10901 && zipCode <= 10998) ||
             (zipCode >= 12007 && zipCode <= 14925))
    {
        coalPercentage = 14.4853;
        oilPercentage = 0.9024;
        gasPercentage = 18.9282;
        nuclearPercentage = 30.5892;
        hydroPercentage = 30.7896;
        renewablePercentage = 3.9481;
        biomassPercentage = 1.5950;
        windPercentage = 2.3530;
        solarPercentage = 0.0;
        geothermalPercentage = 0.0;
    }
    //RFCE
    else if ((zipCode >= 21601 && zipCode <= 21930) ||
             (zipCode >= 20201 && zipCode <= 21412) ||
             (zipCode >= 16201 && zipCode <= 20098) ||
             (zipCode >= 15701 && zipCode <= 15963) ||
             (zipCode >= 7001 && zipCode <= 8989) ||
             (zipCode == 152))
    {
        coalPercentage = 35.3677;
        oilPercentage = 0.7271;
        gasPercentage = 17.1304;
        nuclearPercentage = 42.9614;
        hydroPercentage = 1.2358;
        renewablePercentage = 1.7316;
        biomassPercentage = 1.3211;
        windPercentage = 0.4050;
        solarPercentage = 0.0055;
        geothermalPercentage = 0.0;
    }
    //RFCM
    else if ((zipCode >= 48001 && zipCode <= 49802))
    {
        coalPercentage = 71.9861;
        oilPercentage = 0.4093;
        gasPercentage = 9.5071;
        nuclearPercentage = 15.2782;
        hydroPercentage = 0.0;
        renewablePercentage = 2.2211;
        biomassPercentage = 1.8820;
        windPercentage = 0.3391;
        solarPercentage = 0.0;
        geothermalPercentage = 0.0;
    }
    //RFCW
    else if ((zipCode >= 60001 && zipCode <= 61132) ||
             (zipCode >= 53001 && zipCode <= 53408) ||
             (zipCode >= 43001 && zipCode <= 47997) ||
             (zipCode >= 24001 && zipCode <= 26886) ||
             (zipCode >= 21501 && zipCode <= 21562) ||
             (zipCode >= 16001 && zipCode <= 16172) ||
             (zipCode >= 15001 && zipCode <= 15698))
    {
        coalPercentage = 69.8826;
        oilPercentage = 0.4022;
        gasPercentage = 3.5051;
        nuclearPercentage = 23.5563;
        hydroPercentage = 0.7949;
        renewablePercentage = 1.4412;
        biomassPercentage = 0.5057;
        windPercentage = 0.9355;
        solarPercentage = 0.0;
        geothermalPercentage = 0.0;
    }
    //RMPA
    else if ((zipCode >= 80001 && zipCode <= 82845) ||
             (zipCode >= 69121 && zipCode <= 69367) ||
             (zipCode == 27))
    {
        coalPercentage = 67.7689;
        oilPercentage = 0.0435;
        gasPercentage = 22.5989;
        nuclearPercentage = 0.0;
        hydroPercentage = 4.3045;
        renewablePercentage = 5.1982;
        biomassPercentage = 0.0911;
        windPercentage = 5.0659;
        solarPercentage = 0.0412;
        geothermalPercentage = 0.0;
    }
    //SPNO
    else if ((zipCode >= 660022 && zipCode <= 67954) ||
             (zipCode >= 64001 && zipCode <= 64199))
    {
        coalPercentage = 73.8392;
        oilPercentage = 0.2559;
        gasPercentage = 7.8088;
        nuclearPercentage = 13.4882;
        hydroPercentage = 0.1377;
        renewablePercentage = 4.4333;
        biomassPercentage = 0.0289;
        windPercentage = 4.4044;
        solarPercentage = 0.0;
        geothermalPercentage = 0.0;
    }
    //SPSO
    else if ((zipCode >= 88101 && zipCode <= 88267) ||
             (zipCode >= 79001 && zipCode <= 79499) ||
             (zipCode >= 75551 && zipCode <= 75694) ||
             (zipCode >= 72701 && zipCode <= 74966) ||
             (zipCode >= 71301 && zipCode <= 71497) ||
             (zipCode >= 71004 && zipCode <= 71172) ||
             (zipCode >= 65801 && zipCode <= 65899) ||
             (zipCode == 67))
    {
        coalPercentage = 55.2342;
        oilPercentage = 0.1667;
        gasPercentage = 33.8651;
        nuclearPercentage = 0.0;
        hydroPercentage = 5.5274;
        renewablePercentage = 4.9850;
        biomassPercentage = 1.2052;
        windPercentage = 3.7798;
        solarPercentage = 0.0;
        geothermalPercentage = 0.0;
    }
    //SRMV
    else if ((zipCode >= 77597 && zipCode <= 77726) ||
             (zipCode >= 71601 && zipCode <= 72687) ||
             (zipCode >= 71201 && zipCode <= 71295) ||
             (zipCode >= 70001 && zipCode <= 71003) ||
             (zipCode >= 38901 && zipCode <= 39296) ||
             (zipCode == 116) ||
             (zipCode == 119) ||
             (zipCode == 121))
    {
        coalPercentage = 22.7319;
        oilPercentage = 1.4534;
        gasPercentage = 45.0929;
        nuclearPercentage = 25.9742;
        hydroPercentage = 1.7270;
        renewablePercentage = 1.9253;
        biomassPercentage = 1.9253;
        windPercentage = 0.0;
        solarPercentage = 0.0;
        geothermalPercentage = 0.0;
    }
    //SRMW
    else if ((zipCode >= 64401 && zipCode <= 65793) ||
             (zipCode >= 61301 && zipCode <= 63967))
    {
        coalPercentage = 79.7879;
        oilPercentage = 0.0884;
        gasPercentage = 1.0399;
        nuclearPercentage = 17.1754;
        hydroPercentage = 1.7552;
        renewablePercentage = 0.2410;
        biomassPercentage = 0.1270;
        windPercentage = 0.1140;
        solarPercentage = 0.0;
        geothermalPercentage = 0.0;
    }
    //SRSO
    else if ((zipCode >= 38401 && zipCode <= 39901) ||
             (zipCode >= 38701 && zipCode <= 38782) ||
             (zipCode >= 36003 && zipCode <= 36925) ||
             (zipCode >= 35401 && zipCode <= 35504) ||
             (zipCode >= 35004 && zipCode <= 35188) ||
             (zipCode >= 32401 && zipCode <= 32592) ||
             (zipCode >= 30801 && zipCode <= 31999) ||
             (zipCode >= 30002 && zipCode <= 30683))
    {
        coalPercentage = 52.1843;
        oilPercentage = 0.3499;
        gasPercentage = 22.3083;
        nuclearPercentage = 18.0664;
        hydroPercentage = 4.0925;
        renewablePercentage = 2.9228;
        biomassPercentage =2.9228;
        windPercentage = 0.0;
        solarPercentage = 0.0;
        geothermalPercentage = 0.0;
    }
    //SRTV
    else if ((zipCode >= 40003 && zipCode <= 42788) ||
             (zipCode >= 39298 && zipCode <= 39367) ||
             (zipCode >= 38801 && zipCode <= 38880) ||
             (zipCode >= 37010 && zipCode <= 38686) ||
             (zipCode >= 35540 && zipCode <= 35990) ||
             (zipCode >= 35201 && zipCode <= 35298) ||
             (zipCode >= 30701 && zipCode <= 30757))
    {
        coalPercentage = 58.8034;
        oilPercentage = 0.9387;
        gasPercentage = 8.6065;
        nuclearPercentage = 22.1286;
        hydroPercentage = 8.5808;
        renewablePercentage = 0.9333;
        biomassPercentage = 0.7817;
        windPercentage = 0.1516;
        solarPercentage = 0.0;
        geothermalPercentage = 0.0;
    }
    //SRVC
    else if ((zipCode >= 27006 && zipCode <= 29945) ||
             (zipCode >= 22003 && zipCode <= 23976) ||
             (zipCode >= 20101 && zipCode <= 20198) ||
             (zipCode == 84))
    {
        coalPercentage = 45.1039;
        oilPercentage = 0.6421;
        gasPercentage = 8.9501;
        nuclearPercentage = 41.3467;
        hydroPercentage = 1.6491;
        renewablePercentage = 2.0482;
        biomassPercentage = 2.0466;
        windPercentage = 0.0;
        solarPercentage = 0.0016;
        geothermalPercentage = 0.0;
    }
}

-(double)totalPercentages
{
    double total = coalPercentage + gasPercentage + oilPercentage + hydroPercentage + nuclearPercentage + renewablePercentage + otherPercentage + windPercentage + solarPercentage + biomassPercentage + geothermalPercentage;
    return total;
}

@end
