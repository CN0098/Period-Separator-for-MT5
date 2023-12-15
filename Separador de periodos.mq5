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
//| Función de iteración del indicador personalizado                |
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
   int lastTrendlineIndex = -1; // Almacena el índice de la última vela donde se dibujó una línea de tendencia
                                // A este código le falta una función de "next trendline index", que representaría el punto
                                // donde el siguiente time[i] iría colocado. Porque funciona, pero la trendline del período en curso no pinta.
                                // Ahora, de la misma manera que calculaste el índice de la vela anterior, necesitaría implementar un cálculo para la vela siguiente. Algo así como "el time[i]+1"... ya que la trendline para el último período, que es el que está aún en curso, no tiene cómo dibujarse.
   for(int i = prev_calculated; i < rates_total; i++)
   {
      TimeToStruct(time[i], t2);
      if ((Period() == PERIOD_D1 && t2.mon != lastMonth && t2.day_of_week >= 1 && t2.day_of_week <= 5) || 
          (Period() == PERIOD_W1 && t2.mon == 1 && t2.day <= 7) ||
          (Period() == PERIOD_MN1 && t2.mon == 1 && t2.day == 1) ||
          (Period() == PERIOD_H4 && t2.day_of_week == 1 && t2.hour == 0 && t2.min == 0 && lastTime != time[i]) ||
          (Period() <= PERIOD_H3 && t2.hour == SeparatorHour && t2.min == SeparatorMinute && lastTime != time[i])) 
      {
         // Crear una nueva línea vertical
         string name = "vline_" + TimeToString(time[i], TIME_DATE|TIME_MINUTES);
         ObjectCreate(0, name, OBJ_VLINE, 0, time[i], 0);
         ObjectSetInteger(0, name, OBJPROP_COLOR, LineColor);
         ObjectSetInteger(0, name, OBJPROP_STYLE, LineStyle);
         ObjectSetInteger(0, name, OBJPROP_WIDTH, LineWidth);
         ObjectSetInteger(0, name, OBJPROP_BACK, true);

         // Crear una nueva línea de tendencia
         if(lastTrendlineIndex != -1)
         {
            string trendline_name = "trendline_" + TimeToString(time[lastTrendlineIndex], TIME_DATE|TIME_MINUTES);
            ObjectCreate(0, trendline_name, OBJ_TREND, 0, time[lastTrendlineIndex], open[lastTrendlineIndex], time[i], open[lastTrendlineIndex]);
            ObjectSetInteger(0, trendline_name, OBJPROP_COLOR, clrWhite);
            ObjectSetInteger(0, trendline_name, OBJPROP_STYLE, STYLE_SOLID);
            ObjectSetInteger(0, trendline_name, OBJPROP_WIDTH, 2);
            ObjectSetInteger(0, trendline_name, OBJPROP_BACK, true);
         }
         lastTrendlineIndex = i;

         lastTime = time[i];
         if (Period() == PERIOD_D1) lastMonth = t2.mon;
      }
   }
   return(rates_total);
}
