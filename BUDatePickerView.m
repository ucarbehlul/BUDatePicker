/*
//  BUDatePickerView.m
//
//  Created by Behlul UCAR on 4/3/12.
//
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "BUDatePickerView.h"

#define SECS_IN_DAY 60*60*24

@interface BUDatePickerView()

@property (strong) NSDateFormatter* dateFormatter;
@property (assign) int dayComponent;
@property (assign) int monthComponent;
@property (assign) int yearComponent;
@property (assign) BOOL hasEverMadeSelection; //this is to solve a crash in numberofrowsincomponent which occurs when no selection made.

-(NSDate*)getClosestDate;
-(NSInteger)yearOffset;

@end

@implementation BUDatePickerView

@synthesize dateFormatter;
@synthesize dayComponent, monthComponent, yearComponent;
@synthesize minimumDate, maximumDate;
@synthesize hasEverMadeSelection;
@synthesize bounded;

#pragma mark init

-(void)postInit {
    self.dataSource = self;
    self.delegate = self;
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle:NSDateFormatterShortStyle];        
    [self.dateFormatter setDateFormat:@"MM/dd/yyyy"];
    [self.dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    self.monthComponent = 0;    
    self.dayComponent = 1;
    self.yearComponent = 2;
    self.hasEverMadeSelection = NO;
}

-(id)init {
    self = [super init];
    if (self) {
        [self postInit];
    }
    return self;    
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];    
    if (self) {
        [self postInit];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self postInit];
    }
    return self;    
}

#pragma mark setter&getter
-(void)setMinimumDate:(NSDate *)p_minimumDate {
    //zero seconds on the same day
    minimumDate = [NSDate dateWithTimeIntervalSinceReferenceDate:
                   floor([p_minimumDate timeIntervalSinceReferenceDate]/((float)SECS_IN_DAY))*SECS_IN_DAY]; 
    //the 10 above is for making sure that day component of the date is correct. 
}

-(void)setMaximumDate:(NSDate *)p_maximumDate {
    //full seconds on the same day
    maximumDate = [NSDate dateWithTimeIntervalSinceReferenceDate:
                   floor([p_maximumDate timeIntervalSinceReferenceDate]/((float)SECS_IN_DAY))*SECS_IN_DAY - 60];
}
#pragma mark helper methods


-(NSInteger)daysInMonth:(int)month andYear:(int)year {
    int daysInMonth = 28;
    if ([self.dateFormatter dateFromString:[NSString stringWithFormat:@"%2d/%2d/%4d", month, 29, year]]) {
        daysInMonth++;
    }
    if ([self.dateFormatter dateFromString:[NSString stringWithFormat:@"%2d/%2d/%4d", month, 30, year]]) {
        daysInMonth++;
    }    
    if ([self.dateFormatter dateFromString:[NSString stringWithFormat:@"%2d/%2d/%4d", month, 31, year]]) {
        daysInMonth++;
    }    
    return daysInMonth;
}

-(NSDate*)getSelectedDate {
    NSDate* selectedDate = [self getClosestDate];
    if (selectedDate==nil) {
        return selectedDate;
    }
    if (self.minimumDate && [selectedDate compare:self.minimumDate]==NSOrderedAscending) {
        return self.minimumDate;
    }
    if (self.maximumDate && [selectedDate compare:self.maximumDate]==NSOrderedDescending) {
        return self.maximumDate;
    }
    return selectedDate;
}

-(NSDate*)getClosestDate {
    int day = [self selectedRowInComponent:self.dayComponent]+1;
    int month = [self selectedRowInComponent:self.monthComponent]+1;
    int year = [self selectedRowInComponent:self.yearComponent]+[self yearOffset];
    NSDate* selectedDate = [self.dateFormatter dateFromString:
                            [NSString stringWithFormat:@"%2d/%2d/%4d", month, day, year]];
    return selectedDate;
}

-(void)setSelectedDate:(NSDate *)selectedDate {
    int which = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents* comps= [[NSCalendar currentCalendar] components:which
                                                             fromDate:selectedDate];
    [self selectRow:comps.year-[self yearOffset] inComponent:self.yearComponent animated:NO];
    [self selectRow:comps.month-1 inComponent:self.monthComponent animated:NO];
    [self selectRow:comps.day-1 inComponent:self.dayComponent animated:NO];
    self.hasEverMadeSelection = YES;
    [self reloadAllComponents];        
}

#pragma mark UIPickerView datasource
-(NSInteger)yearOffset {
    return self.bounded ? self.minimumDate.year : 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView
        numberOfRowsInComponent:(NSInteger)component {
    if (component==self.monthComponent)  {
        return 12;
    } else if (component == self.dayComponent) {
        return hasEverMadeSelection ?
            [self daysInMonth:[self selectedRowInComponent:self.monthComponent]+1 
                      andYear:[self selectedRowInComponent:self.yearComponent]+[self yearOffset]] : 30;
    } else if (component == self.yearComponent) {
        return self.bounded ? self.maximumDate.year - self.minimumDate.year + 1 : 3000;
    } else {
        return -1;
    }
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

#pragma mark UIPickerView delegate
-(float)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 35;
}

-(float)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    if (component==self.yearComponent) {
        return 70;
    }
    if (component==self.monthComponent) {
        return 160;
    }
    else  {
        return 40;
    }
}


-(UIView*)pickerView:(UIPickerView *)pickerView
          viewForRow:(NSInteger)row
        forComponent:(NSInteger)component
         reusingView:(UIView *)view {
    NSString* text;
    if (component == self.monthComponent) {
        text = [[self.dateFormatter monthSymbols] objectAtIndex:row];
    } else if (component== self.yearComponent){
        text = [NSString stringWithFormat:@"%d", row+[self yearOffset]];
    } else {
        text = [NSString stringWithFormat:@"%d", row+1];
    }
    if (view == nil) {
        CGRect frame = CGRectMake(
                                  0,
                                  0, 
                                  [self pickerView:self widthForComponent:component],
                                  [self pickerView:self rowHeightForComponent:component]);
        UILabel* label = [[UILabel alloc] initWithFrame:frame];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:20];
        label.textAlignment = UITextAlignmentCenter;
        view = label;
    }
    ((UILabel*)view).text = text;    
    int day = (component == self.dayComponent) ? row+1 : [self selectedRowInComponent:self.dayComponent]+1;
    int month = (component == self.monthComponent) ? row+1 : [self selectedRowInComponent:self.monthComponent]+1;    
    int year = (component == self.yearComponent)
        ? row + [self yearOffset]
        : [self selectedRowInComponent:self.yearComponent] + [self yearOffset];
    NSDate* rowDate = [self.dateFormatter dateFromString:[NSString stringWithFormat:@"%2d/%2d/%4d", month, day, year]];
    if ((self.minimumDate && [rowDate compare:self.minimumDate] == NSOrderedAscending) ||
        (self.maximumDate && [rowDate compare:self.maximumDate] == NSOrderedDescending)) {
        ((UILabel*)view).textColor = [UIColor grayColor];
    } else {
        ((UILabel*)view).textColor = [UIColor blackColor];        
    }
    return view;
}

-(void)pickerView:(UIPickerView *)pickerView
     didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component {
    [self reloadAllComponents];
    //check date bounds if date is valid
    NSDate* selectedDate = [self getClosestDate];
    if (selectedDate != nil) {
        int which = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
        NSCalendar* calendar = [NSCalendar currentCalendar];
        [calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        if (self.minimumDate && [selectedDate compare:self.minimumDate]==NSOrderedAscending) {
            NSDateComponents* comps= [calendar components:which fromDate:self.minimumDate];
            [self selectRow:comps.month-1 inComponent:self.monthComponent animated:NO];
            [self selectRow:comps.day-1 inComponent:self.dayComponent animated:NO];
            [self selectRow:comps.year-[self yearOffset] inComponent:self.yearComponent animated:NO];
            [self reloadAllComponents];
        } else if (self.maximumDate && [selectedDate compare:self.maximumDate]==NSOrderedDescending) {
            NSDateComponents* comps= [calendar components:which fromDate:self.maximumDate];
            [self selectRow:comps.month-1 inComponent:self.monthComponent animated:NO];
            [self selectRow:comps.day-1 inComponent:self.dayComponent animated:NO];
            [self selectRow:comps.year-[self yearOffset] inComponent:self.yearComponent animated:NO];
            [self reloadAllComponents];            
        }
    }
}
#pragma mark -

@end
