/*
    Copyright 2015 Christie Dierk
*/


#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "EnergyDataGetter.h"
#import "EnergyDistribution.h"

@interface MainScene : CCNode
{
    CCSprite * selSprite;
    NSMutableArray * movableSprites;
    
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    NSManagedObjectContext *context;
    CCAppDelegate *appDelegate;
    NSFetchRequest *fetchRequest;
    NSEntityDescription *entity;
    NSArray *fetchedObjects;
    BOOL isCharging;
    EnergyDistribution *distribution;
    double totalCoalPercentage, totalOilPercentage, totalGasPercentage, totalNuclearPercentage, totalHydroPercentage, totalRenewablePercentage, totalOtherFossilPercentage, totalGeothermalPercentage, totalWindPercentage, totalSolarPercentage, totalBiomassPercentage, totalBiogasPercentage, totalPercentage;
    double currentCoalPercentage, currentOilPercentage, currentGasPercentage, currentNuclearPercentage, currentHydroPercentage, currentRenewablePercentage, currentOtherPercentage, currentGeothermalPercentage, currentWindPercentage, currentSolarPercentage, currentBiomassPercentage, currentBiogasPercentage, currentTotalPercentage, startCharge, previousCoalPercentage, previousOilPercentage, previousGasPercentage, previousNuclearPercentage, previousHydroPercentage, previousRenewablePercentage, previousOtherPercentage, previousGeothermalPercentage, previousWindPercentage, previousSolarPercentage, previousBiomassPercentage, previousBiogasPercentage, previousTotalPercentage;
    BOOL hasDistribution;
    CCNode *coalBubble, *oilBubble, *gasBubble, *nuclearBubble, *hydroBubble, *otherBubble, *geothermalBubble, *windBubble, *solarBubble, *biomassBubble, *biogasBubble;
}
@property NSManagedObject *currentDistribution;
@property NSDate *startDate;
@property NSDate *endDate;
@property float startChargePercentage;
@property float endChargePercentage;
@property float percentCharged;
@property NSTimeInterval secondsSpentCharging;
@property (weak, nonatomic) IBOutlet UITextView *locationText;
@property (weak, nonatomic) IBOutlet UITextView *dateText;

-(void) getUpdatedData;
-(void) concatDistributions;
-(void) setDistributionDisplay: (NSManagedObject*) distribution;
- (IBAction)updateDisplay:(id)sender;
-(void) math;
@end
