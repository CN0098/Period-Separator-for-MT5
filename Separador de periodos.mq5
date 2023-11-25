//±-----------------------------------------------------------------+
//| Period Separator.mq5                                            |
//| Copyright 2023, MetaQuotes Software Corp.                        |
//| https://www.mql5.com                                             |
//±-----------------------------------------------------------------+

#property copyright "MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window

input color           LineColor       = clrSilver;  // Line color
input ENUM_LINE_STYLE LineStyle       = STYLE_DOT;  // Line style
input int             LineWidth       = 1;          // Line width
input int             SeparatorHour   = 0;          // Separator hour
input int             SeparatorMinute = 0;          // Separator minute

datetime lastTime = 0;
int lastMonth = 0;

//±-----------------------------------------------------------------+
//| Custom indicator initialization function                        |
//±-----------------------------------------------------------------+
int OnInit()
{
   // Delete all existing lines on initialization
   for(int i=ObjectsTotal(0)-1; i>=0; i--) 
   {
      string name = ObjectName(0, i);
      if(ObjectGetInteger(0, name, OBJPROP_TYPE) == OBJ_VLINE)
         ObjectDelete(0, name);
   }
   return(INIT_SUCCEEDED);
}

//±-----------------------------------------------------------------+
//| Custom indicator iteration function                             |
//±-----------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   MqlDateTime t2;

   for(int i = prev_calculated; i < rates_total; i++)
   {
      TimeToStruct(time[i], t2);
      if ((Period() == PERIOD_D1 && t2.mon != lastMonth && t2.day_of_week >= 1 && t2.day_of_week <= 5) || 
          (Period() == PERIOD_W1 && t2.mon == 1 && t2.day <= 7) ||
          (Period() == PERIOD_MN1 && t2.mon == 1 && t2.day == 1) ||
          (Period() == PERIOD_H4 && t2.day_of_week == 1 && t2.hour == 0 && t2.min == 0 && lastTime != time[i]) ||
          (Period() <= PERIOD_H3 && t2.hour == SeparatorHour && t2.min == SeparatorMinute && lastTime != time[i])) 
      {
         // Create a new vertical line
         string name = "vline_" + TimeToString(time[i], TIME_DATE|TIME_MINUTES);
         ObjectCreate(0, name, OBJ_VLINE, 0, time[i], 0);
         ObjectSetInteger(0, name, OBJPROP_COLOR, LineColor);
         ObjectSetInteger(0, name, OBJPROP_STYLE, LineStyle);
         ObjectSetInteger(0, name, OBJPROP_WIDTH, LineWidth);
         ObjectSetInteger(0, name, OBJPROP_BACK, true);
         lastTime = time[i];
         if (Period() == PERIOD_D1) lastMonth = t2.mon;
      }
   }
   return(rates_total);
}
