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

#import <UIKit/UIKit.h>

@interface BUDatePickerView : UIPickerView<UIPickerViewDataSource, UIPickerViewDelegate>
{
    NSDate* minimumDate;
}

@property (strong, nonatomic) NSDate* minimumDate;
@property (strong, nonatomic) NSDate* maximumDate;
/*
 * if you want the picker to be bounded by minimum
 * maximum dates, set true
 */
@property (assign) BOOL bounded;

/**
 * Returns currently selected date if it is valid or nil
 * returns a date in the maximum and minimum bound
 */
-(NSDate*)getSelectedDate;
-(void)setSelectedDate:(NSDate *)selectedDate;

-(NSDate*)getClosestDate;
@end
