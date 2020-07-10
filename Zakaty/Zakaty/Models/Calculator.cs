using System;
using System.Collections.Generic;
using System.Text;

namespace Zakaty.Models
{
    class Calculator
    {
        public double GoldPrice { get; set; }
        public double SilverPrice { get; set; }
        public double NaturallyCropsPrice { get; set; }
        public double IrrigatedWaterCropsPrice { get; set; }
        public double CashOnHand { get; set; }
        public double LoanCash { get; set; }
        public double SharesProfit { get; set; }
        public double SaleableStock { get; set; }
        public double LiabilitiesDebts { get; set; }
        public double PriceOfLand { get; set; }



        public double All()
        {
            double all = GoldPrice + SilverPrice + NaturallyCropsPrice + IrrigatedWaterCropsPrice + CashOnHand +
                         LoanCash + LiabilitiesDebts + SaleableStock + SharesProfit + PriceOfLand;
            return all;
        }
    }
}
