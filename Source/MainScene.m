#import "MainScene.h"

#define BUBBLE_SCALE 1.5
#define DENSITY_SCALE 10
#define COAL_INDEX 0
#define OIL_INDEX 1
#define GAS_INDEX 2
#define NUCLEAR_INDEX 3
#define OTHER_INDEX 4
#define HYDRO_INDEX 5
#define GEOTHERMAL_INDEX 6
#define WIND_INDEX 7
#define SOLAR_INDEX 8
#define BIOMASS_INDEX 9
#define BIOGAS_INDEX 10

@implementation MainScene{
    CCPhysicsNode *_physicsNode;
    CCSprite *_currentlySelectedBubble;
}

@synthesize currentDistribution;

- (void)touchBegan:(CCTouch *)touch withEvent:(UIEvent *)event
{
    NSLog(@"Touch detected");
    _currentlySelectedBubble = [self getSpriteAtPosition: touch.locationInWorld];
}

- (void) touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    if (_currentlySelectedBubble) {
        _currentlySelectedBubble.position = touch.locationInWorld;
    }
}

- (void) touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    NSLog(@"Touch ended");
    _currentlySelectedBubble = NULL;
}


//this doesn't work, always selects coalbubble
- (CCSprite*) getSpriteAtPosition: (CGPoint) inTouchPosition
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    //might have to adjust this, basically assuming that one bubble will never get this large
    CGFloat maxWidth = screenWidth * BUBBLE_SCALE;
    
    for (CCSprite* sprite in [_physicsNode children]){
        if ([[sprite name] isEqual:@"bubble"]){
            UIView *aView = [[UIView alloc]initWithFrame:CGRectMake(sprite.position.x, sprite.position.y, sprite.boundingBox.size.width, sprite.boundingBox.size.height)];
            BOOL isPointInsideView = [aView pointInside:inTouchPosition withEvent:nil];
            if (isPointInsideView){
                NSLog(@"%@", [sprite name]);
                return sprite;
            }
        }
    }
    return NULL;
}

// is called when CCB file has completed loading
- (void)didLoadFromCCB {
    // tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
    [self initializeBubbles];
    
    _currentlySelectedBubble = NULL;
    
    hasDistribution = NO;
    
    // Do any additional setup after loading the view, typically from a nib.
    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(batteryStateDidChange:)
                                                 name:UIDeviceBatteryStateDidChangeNotification
                                               object:nil];
    
    //sample values for testing
    startCharge = 0;

    currentCoalPercentage = 0.5;
    currentOilPercentage = 0.0;
    currentGasPercentage = 0.299;
    currentNuclearPercentage = 0;
    currentHydroPercentage = 0.1;
    currentGeothermalPercentage = 0;
    currentRenewablePercentage = 0.0;
    currentWindPercentage = 0.01;
    currentSolarPercentage = 0.1;
    currentBiomassPercentage = 0;
    currentBiogasPercentage = 0;
    currentOtherPercentage = 0.0 ;
    currentTotalPercentage = 1;
    
    //save current values for previous charge
    //should check to see if there are values for previous variables. Patched for now
    if (!previousBiogasPercentage){
        previousCoalPercentage = currentCoalPercentage;
        previousOilPercentage = currentOilPercentage;
        previousGasPercentage = currentGasPercentage;
        previousNuclearPercentage = currentGasPercentage;
        previousNuclearPercentage = currentNuclearPercentage;
        previousHydroPercentage = currentHydroPercentage;
        previousGeothermalPercentage = currentGeothermalPercentage;
        previousRenewablePercentage = currentRenewablePercentage;
        previousWindPercentage = currentWindPercentage;
        previousSolarPercentage = currentSolarPercentage;
        previousBiomassPercentage = currentBiomassPercentage;
        previousBiogasPercentage = currentBiogasPercentage;
        previousTotalPercentage = currentTotalPercentage;
    }
    
    //Should actually check instead of just initializing to no
    isCharging = NO;
    
    locationManager.delegate = self;
    
    //CHANGE THE ACCURACY!
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [self updateDisplay];
}

//works when app is in foreground
- (void)batteryStateDidChange:(NSNotification *)notification {
    if (([[UIDevice currentDevice] batteryState] == UIDeviceBatteryStateCharging)) {
        isCharging = YES;
        
        NSLog(@"Now charging");
        
        UIAlertView *chargingAlert = [[UIAlertView alloc] initWithTitle:@"Charging" message:@"Your device is now charging" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [chargingAlert show];
        
        //get new values for current charge
        [self clearLocation];
        
        _startDate = [NSDate date];
        _startChargePercentage = [[UIDevice currentDevice] batteryLevel];
        startCharge = [[UIDevice currentDevice] batteryLevel];
        
        //commented out for now
        //[locationManager startUpdatingLocation];
        
        //sample values
        currentCoalPercentage = 0.1;
        currentOilPercentage = 0.2;
        currentGasPercentage = 0.0;
        currentNuclearPercentage = 0.5;
        currentHydroPercentage = 0;
        currentGeothermalPercentage = 0;
        currentWindPercentage = 0.2;
        currentSolarPercentage = 0.0;
        currentBiomassPercentage = 0;
        currentBiogasPercentage = 0;
        currentOtherPercentage = 0;
        currentTotalPercentage = 1;
    }
    else if ([[UIDevice currentDevice] batteryState] == UIDeviceBatteryStateUnplugged) {
        
        //phone is unplugged
        isCharging = NO;
        _endDate = [NSDate date];
        _endChargePercentage = [[UIDevice currentDevice] batteryLevel];
        
        [self concatDistributions];
        startCharge = [[UIDevice currentDevice] batteryLevel];
        
        _secondsSpentCharging = [_endDate timeIntervalSinceDate:_startDate];
        
        UIAlertView *unpluggedAlert = [[UIAlertView alloc] initWithTitle:@"Unplugged" message:@"Your device is no longer charging" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [unpluggedAlert show];
    }
}

- (IBAction)updateLocation:(id)sender{
    //commented out until API is working again
    /*//NSLog(@"Update Location button pressed");
     [self clearLocation];
     //NSLog(@"Device is charging");
     
     
     //CHANGE THE UPDATE FREQUENCY!
     [locationManager startUpdatingLocation];*/
    
    [self hardCodedSetPercentages];
    //[self batteryStateDidChange:(NULL)];
    
}

-(void) clearLocation
{
    _locationText.text = @"";
    _dateText.text = @"";
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    //NSLog(@"Failed with error: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not get location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *currentLocation = [locations lastObject];
    //NSLog(@"Updated to location: %@", currentLocation);
    distribution = [[EnergyDistribution alloc] initWithLatLon: currentLocation.coordinate.latitude :currentLocation.coordinate.longitude];
    [self setPercentages];
    
    if (currentLocation != nil)
    {
        //_LocationText.text = [NSString stringWithFormat: @"Longitude: %.8f Latitude: %.8f", currentLocation.coordinate.longitude, currentLocation.coordinate.latitude];
    }
    
    [locationManager stopUpdatingLocation];
}

-(void) getUpdatedData
{
    appDelegate = (CCAppDelegate*) [[UIApplication sharedApplication] delegate];
    context = appDelegate.managedObjectContext;
    
    NSError *error;
    fetchRequest = [[NSFetchRequest alloc] init];
    entity = [NSEntityDescription
              entityForName:@"EnergyDistribution" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
}


-(void) saveDistribution
{
    NSNumber* postalCode;
    postalCode = [NSNumber numberWithInt:[[placemark postalCode] integerValue]];
    NSError *error;
    
    NSManagedObject *last = [fetchedObjects lastObject];
    NSManagedObject *energyDistribution = [NSEntityDescription
                                           insertNewObjectForEntityForName:@"EnergyDistribution"
                                           inManagedObjectContext:context];
    [energyDistribution setValue:postalCode forKey:@"zip"];
    //NSLog(@"Zip put in is %@", postalCode);
    [energyDistribution setValue:[NSDate date] forKey:@"date"];
    [energyDistribution setValue:[placemark locality] forKey:@"city"];
    [energyDistribution setValue:[placemark administrativeArea] forKey:@"state"];
    
    if (last != nil) {
        [energyDistribution setValue:last forKey:@"previousDistribution"];
        [last setValue:energyDistribution forKey:@"nextDistribution"];
    }
    
    currentDistribution = energyDistribution;
    
    if (![context save:&error]) {
        //NSLog(@"Couldn't save: %@", [error localizedDescription]);
    }
}

-(void) hardCodedSetPercentages {
    currentCoalPercentage = 0.5;
    currentOilPercentage = 0.0;
    currentGasPercentage = 0.299;
    currentNuclearPercentage = 0.0;
    currentHydroPercentage = 0.1;
    currentRenewablePercentage = 0.0;
    currentOtherPercentage = 0.0;
    //NSLog(@"Other percentage in view controller is %f", currentOtherPercentage);
    currentGeothermalPercentage = 0.0;
    currentSolarPercentage = 0.1;
    currentWindPercentage = 0.01;
    currentBiomassPercentage = 0.0;
    currentBiogasPercentage = 0.0;
    currentTotalPercentage = 1.0;
}

-(void) setPercentages
{
    currentCoalPercentage = [distribution coalPercentage];
    currentOilPercentage = [distribution oilPercentage];
    currentGasPercentage = [distribution gasPercentage];
    currentNuclearPercentage = [distribution nuclearPercentage];
    currentHydroPercentage = [distribution hydroPercentage];
    currentRenewablePercentage = [distribution renewablePercentage];
    currentOtherPercentage = [distribution otherPercentage];
    //NSLog(@"Other percentage in view controller is %f", currentOtherPercentage);
    currentGeothermalPercentage = [distribution geothermalPercentage];
    currentSolarPercentage = [distribution solarPercentage];
    currentWindPercentage = [distribution windPercentage];
    currentBiomassPercentage = [distribution biomassPercentage];
    currentBiogasPercentage = [distribution biogasPercentage];
    currentTotalPercentage = [distribution totalPercentages];
}

//data already gathered from API, simply update display from it
- (IBAction)updateDisplay {
    
    NSLog(@"Update Display");
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    //might have to adjust this, basically assuming that one bubble will never get this large
    CGFloat maxWidth = screenWidth * BUBBLE_SCALE;
    
    //need to add something here to remove previous bubbles
    
    if (currentCoalPercentage > 0){
        [_physicsNode addChild:coalBubble z:0 name:@"bubble"];
        [coalBubble setScaleX:(currentCoalPercentage * maxWidth) / coalBubble.contentSize.width];
        [coalBubble setScaleY:(currentCoalPercentage * maxWidth) / coalBubble.contentSize.height];
        coalBubble.physicsBody.density = currentCoalPercentage * DENSITY_SCALE;
    }
    if (currentOilPercentage > 0){
        [_physicsNode addChild:oilBubble z:0 name:@"bubble"];
        [oilBubble setScaleX:(currentOilPercentage * maxWidth) / oilBubble.contentSize.width];
        [oilBubble setScaleY:(currentOilPercentage * maxWidth) / oilBubble.contentSize.height];
        oilBubble.physicsBody.density = currentOilPercentage * DENSITY_SCALE;
    }
    if (currentGasPercentage > 0){
        [_physicsNode addChild:gasBubble z:0 name:@"bubble"];
        [gasBubble setScaleX:(currentGasPercentage * maxWidth) / gasBubble.contentSize.width];
        [gasBubble setScaleY:(currentGasPercentage * maxWidth) / gasBubble.contentSize.height];
        gasBubble.physicsBody.density = currentGasPercentage * DENSITY_SCALE;
    }
    if (currentNuclearPercentage > 0){
        [_physicsNode addChild:nuclearBubble z:0 name:@"bubble"];
        [nuclearBubble setScaleX:(currentNuclearPercentage * maxWidth) / nuclearBubble.contentSize.width];
        [nuclearBubble setScaleY:(currentNuclearPercentage * maxWidth) / nuclearBubble.contentSize.height];
        nuclearBubble.physicsBody.density = currentNuclearPercentage * DENSITY_SCALE;
    }
    if (currentHydroPercentage > 0){
        [_physicsNode addChild:hydroBubble z:0 name:@"bubble"];
        [hydroBubble setScaleX:(currentHydroPercentage * maxWidth) / hydroBubble.contentSize.width];
        [hydroBubble setScaleY:(currentHydroPercentage * maxWidth) / hydroBubble.contentSize.height];
        hydroBubble.physicsBody.density = currentHydroPercentage * DENSITY_SCALE;
    }
    if (currentOtherPercentage > 0){
        [_physicsNode addChild:otherBubble z:0 name:@"bubble"];
        [otherBubble setScaleX:(currentOtherPercentage * maxWidth) / otherBubble.contentSize.width];
        [otherBubble setScaleY:(currentOtherPercentage * maxWidth) / otherBubble.contentSize.height];
        otherBubble.physicsBody.density = currentOtherPercentage * DENSITY_SCALE;
    }
    if (currentGeothermalPercentage > 0){
        [_physicsNode addChild:geothermalBubble z:0 name:@"bubble"];
        [geothermalBubble setScaleX:(currentGeothermalPercentage * maxWidth) / geothermalBubble.contentSize.width];
        [geothermalBubble setScaleY:(currentGeothermalPercentage * maxWidth) / geothermalBubble.contentSize.height];
        geothermalBubble.physicsBody.density = currentGeothermalPercentage * DENSITY_SCALE;
    }
    if (currentWindPercentage > 0){
        [_physicsNode addChild:windBubble z:0 name:@"bubble"];
        [windBubble setScaleX:(currentWindPercentage * maxWidth) / windBubble.contentSize.width];
        [windBubble setScaleY:(currentWindPercentage * maxWidth) / windBubble.contentSize.height];
        windBubble.physicsBody.density = currentWindPercentage * DENSITY_SCALE;
    }
    if (currentSolarPercentage > 0){
        [_physicsNode addChild:solarBubble z:0 name:@"bubble"];
        [solarBubble setScaleX:(currentSolarPercentage * maxWidth) / solarBubble.contentSize.width];
        [solarBubble setScaleY:(currentSolarPercentage * maxWidth) / solarBubble.contentSize.height];
        solarBubble.physicsBody.density = currentSolarPercentage * DENSITY_SCALE;
    }
    if (currentBiomassPercentage > 0){
        [_physicsNode addChild:biomassBubble z:0 name:@"bubble"];
        [biomassBubble setScaleX:(currentBiomassPercentage * maxWidth) / biomassBubble.contentSize.width];
        [biomassBubble setScaleY:(currentBiomassPercentage * maxWidth) / biomassBubble.contentSize.height];
        biomassBubble.physicsBody.density = currentBiomassPercentage * DENSITY_SCALE;
    }
    if (currentBiogasPercentage > 0){
        [_physicsNode addChild:biogasBubble z:0 name:@"bubble"];
        [biogasBubble setScaleX:(currentBiogasPercentage * maxWidth) / biogasBubble.contentSize.width];
        [biogasBubble setScaleY:(currentBiogasPercentage * maxWidth) / biogasBubble.contentSize.height];
        biogasBubble.physicsBody.density = currentBiogasPercentage * DENSITY_SCALE;
    }
}

//if app is running in background
-(void) math
{
    
    //device is charging
    if ([[UIDevice currentDevice] batteryState] == UIDeviceBatteryStateCharging) {
        NSLog(@"Charging...");
        //if was charging before
        if(isCharging){
            
        }
        //if was not charging before
        else {
            [self clearLocation];
            [locationManager startUpdatingLocation];
            _startDate = [NSDate date];
            _startChargePercentage = [[UIDevice currentDevice] batteryLevel];
            
            NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
            [standardUserDefaults setDouble:currentCoalPercentage forKey:@"currentCoal"];
            [standardUserDefaults setDouble:currentGasPercentage forKey:@"currentGas"];
            [standardUserDefaults setDouble:currentHydroPercentage forKey:@"currentHyrdo"];
            [standardUserDefaults setDouble:currentNuclearPercentage forKey:@"currentNuclear"];
            [standardUserDefaults setDouble:currentOilPercentage forKey:@"currentOil"];
            [standardUserDefaults setDouble:currentRenewablePercentage forKey:@"currentRenewable"];
            [standardUserDefaults setDouble:currentTotalPercentage forKey:@"currentTotal"];
            [standardUserDefaults setDouble:_startChargePercentage forKey:@"startCharge"];
            [standardUserDefaults synchronize];
        }
        isCharging = YES;
    }
    else if ([[UIDevice currentDevice] batteryState] == UIDeviceBatteryStateFull) {
        NSLog(@"Completely charged");
        //if was charging before
        if(isCharging){
            
        }
        //if was not charging before
        else {
            
        }
        isCharging = NO;
    }
    else if ([[UIDevice currentDevice] batteryState] == UIDeviceBatteryStateUnplugged) {
        NSLog(@"Not plugged in");
        //if was charging before
        if (isCharging){
            
        }
        //if was not charging before
        else {
            
        }
        isCharging = NO;
    }
}

//Adds previous charge and current charge when unplugged
- (void) concatDistributions
{
    float currentCharge = [[UIDevice currentDevice] batteryLevel];
    
    currentCoalPercentage = (previousCoalPercentage * startCharge + currentCoalPercentage * (currentCharge - startCharge))/currentCharge;
    currentOilPercentage = (previousOilPercentage * startCharge + currentOilPercentage * (currentCharge - startCharge))/currentCharge;
    currentGasPercentage = (previousGasPercentage * startCharge + currentGasPercentage * (currentCharge - startCharge))/currentCharge;
    currentNuclearPercentage = (previousNuclearPercentage * startCharge + currentNuclearPercentage * (currentCharge - startCharge))/currentCharge;
    currentHydroPercentage = (previousHydroPercentage * startCharge + currentHydroPercentage * (currentCharge - startCharge))/currentCharge;
    currentRenewablePercentage = (previousRenewablePercentage * startCharge + currentRenewablePercentage * (currentCharge - startCharge))/currentCharge;
    currentOtherPercentage = (previousOtherPercentage * startCharge + currentOtherPercentage * (currentCharge - startCharge))/currentCharge;
    currentGeothermalPercentage = (previousGeothermalPercentage * startCharge + currentGeothermalPercentage * (currentCharge - startCharge))/currentCharge;
    currentWindPercentage = (previousWindPercentage * startCharge + currentWindPercentage * (currentCharge - startCharge))/currentCharge;
    currentSolarPercentage = (previousSolarPercentage * startCharge + currentSolarPercentage * (currentCharge - startCharge))/currentCharge;
    currentBiomassPercentage = (previousBiomassPercentage * startCharge + currentBiomassPercentage * (currentCharge - startCharge))/currentCharge;
    currentBiogasPercentage = (previousBiogasPercentage * startCharge + currentBiogasPercentage * (currentCharge - startCharge))/currentCharge;
    
    
    //done with previous values, so reset for next time
    startCharge = 0.0;
    previousCoalPercentage = currentCoalPercentage;
    previousOilPercentage = currentOilPercentage;
    previousGasPercentage = currentGasPercentage;
    previousNuclearPercentage = currentNuclearPercentage;
    previousHydroPercentage = currentHydroPercentage;
    previousRenewablePercentage = currentRenewablePercentage;
    previousOtherPercentage = currentOtherPercentage;
    previousGeothermalPercentage = currentGeothermalPercentage;
    previousWindPercentage = currentWindPercentage;
    previousSolarPercentage = currentSolarPercentage;
    previousBiomassPercentage = currentBiomassPercentage;
    previousBiogasPercentage = currentBiogasPercentage;
    
    //[self setNeedsDisplay];
}

- (void) initializeBubbles {
    coalBubble = [CCBReader load:@"Bubble"];
    oilBubble = [CCBReader load:@"Bubble"];
    gasBubble = [CCBReader load:@"Bubble"];
    nuclearBubble = [CCBReader load:@"Bubble"];
    otherBubble = [CCBReader load:@"Bubble"];
    hydroBubble = [CCBReader load:@"Bubble"];
    geothermalBubble = [CCBReader load:@"Bubble"];
    windBubble = [CCBReader load:@"Bubble"];
    solarBubble = [CCBReader load:@"Bubble"];
    biomassBubble = [CCBReader load:@"Bubble"];
    biogasBubble = [CCBReader load:@"Bubble"];
    
    [coalBubble setColor:[CCColor brownColor]];
    [oilBubble setColor:[CCColor grayColor]];
    [gasBubble setColor:[CCColor blackColor]];
    [nuclearBubble setColor:[CCColor redColor]];
    [otherBubble setColor:[CCColor orangeColor]];
    [hydroBubble setColor:[CCColor blueColor]];
    [geothermalBubble setColor:[CCColor purpleColor]];
    [windBubble setColor:[CCColor cyanColor]];
    [solarBubble setColor:[CCColor yellowColor]];
    [biomassBubble setColor:[CCColor greenColor]];
    [biogasBubble setColor:[CCColor magentaColor]];
    
    coalBubble.position = ccpAdd(ccp(50,50), ccp(16, 50));
    oilBubble.position = ccpAdd(ccp(25,50), ccp(16, 50));
    gasBubble.position = ccpAdd(ccp(75,50), ccp(16, 50));
    nuclearBubble.position = ccpAdd(ccp(100,50), ccp(16, 50));
    otherBubble.position = ccpAdd(ccp(25,75), ccp(16, 50));
    hydroBubble.position = ccpAdd(ccp(50,75), ccp(16, 50));
    geothermalBubble.position = ccpAdd(ccp(75,75), ccp(16, 50));
    windBubble.position = ccpAdd(ccp(100,75), ccp(16, 50));
    solarBubble.position = ccpAdd(ccp(25,100), ccp(16, 50));
    biomassBubble.position = ccpAdd(ccp(50,100), ccp(16, 50));
    biogasBubble.position = ccpAdd(ccp(75,100), ccp(16, 50));
}

@end
