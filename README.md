# Sugar Alternative Whitespace Analysis

This project identifies high-potential US food categories for sugar alternative product launches using USDA nutritional data, Google Trends analysis, and a 4-KPI scoring framework. Key contributions include category filtering logic, SQL-based analytics, and Tableau dashboards revealing opportunities like Candy (93.1 score), Chocolate (76.3), and Wholesome Snacks (76.1).

## Project Overview
The analysis processes 1.99M USDA branded products, filtering to 1.77M US-market items, then creating a 50K stratified sample for analysis. After removing inherently-sugar products (honey, syrups) and low-reformulation categories (<5g avg sugar, <20 products), 25,280 products across 67 categories remain. KPI calculations combine Sugar Load, Market Gap, Market Size, and Consumer Interest Growth to rank categories. SQL queries surface product-level opportunities, and Tableau visualizations enable interactive exploration.

## Key Findings

- **Top 3 Opportunities**: Candy leads at 93.1 score (2,378 products, 89.9% market gap), followed by Chocolate at 76.3 (1,114 products, 86.7% gap) and Wholesome Snacks at 76.1 (724 products, 98.8% gap).
- **Sugar Load**: Top categories average 41.5-59.8g sugar per 100g—0.8-1.2× WHO daily limit, indicating strong reformulation need.
- **Market Gaps**: All top 3 show >86% whitespace (few products with alternatives), signaling low competition.
- **Consumer Trends**: Category-specific searches show Popcorn/Seeds (+12% growth), Candy (+11%), Wholesome Snacks (+7%). Sweetener trends: Monk Fruit (+2.3% growth) vs Stevia (-10% decline).
- **Surprises**: Wholesome Snacks marketed as healthy contain 41.5g sugar/100g yet have 98.8% market gap—untapped reformulation opportunity.

## Recommendations

- **Launch Priority**: Target Candy and Chocolate first—combine for 3,492 products with 88% average market gap and proven consumer demand.
- **Sweetener Choice**: Use Monk Fruit (+2.3% growth, natural positioning) over Stevia (-10% decline) or Sucralose (-14.2% decline).
- **Watch List**: Popcorn/Seeds (2,439 products, highest category growth at +12%) for portfolio expansion.

## Notebooks

- **[Data Processing](scripts/01_process_usda_data.py)**: Cleans USDA data, filters to US products, creates 50K stratified sample.
- **[Data Exploration](notebooks/02_data_exploration.ipynb)**: Sugar alternative detection, category filtering, descriptive statistics.
- **[KPI Calculation](notebooks/03_KPI_calculation.ipynb)**: Calculates Sugar Load, Market Gap, Market Size for 67 categories.
- **[Google Trends Collection](excel/04_google_trends_collection.xlsx)**: Manual extraction of sweetener and category search trends(Top 20 queries per category).
- **[Final Analysis](notebooks/05_final_opportunity_analysis.ipynb)**: Combines trends data, calculates final opportunity scores, assigns priority tiers.

## Tech Stack

- Python (Pandas, NumPy for data wrangling; Matplotlib/Seaborn for visualization)
- Google Trends (manual data collection via web interface)
- PostgreSQL for analytical queries (joins, ranking, product-level identification)
- Tableau for interactive dashboards
- Jupyter/Google Colab for reproducible analysis

## Setup & Run

1. Clone: `git clone https://github.com/annabiloshevska/sugar_alternative_whitespace_analysis.git`
2. Install: `pip install pandas numpy matplotlib seaborn jupyter psycopg2`
3. Get data: Download USDA FoodData Central (https://fdc.nal.usda.gov/download-datasets.html)
4. Run: Execute `scripts/01_process_usda_data.py` locally to create cleaned dataset
5. Analyze: Upload processed CSV to Colab, run notebooks 02 → 03 → 05 sequentially
6. Trends: Manually export Google Trends data (see `excel/04_google_trends_collection.xlsx` as template)
7. Database: Load CSVs to PostgreSQL, run `sql/sugar_alternative_analysis.sql` for queries
8. Dashboard: Open `visualizations/Sugar_Alternative_Whitespace_Analysis.twbx` in Tableau

## Data Sources

**USDA FoodData Central** (December 2025): 1.99M products → 1.77M US → 50K sample → 25,280 after filtering (excluded honey, syrups, inherently-sugar categories; required >5g avg sugar, min 20 products/category)

**Google Trends** (manual extraction): data for 5 sweeteners (stevia, monk fruit, allulose, erythritol, sucralose) and 10 category terms (Top 20 queries per category like "sugar free candy", "low sugar chocolate", etc.)

Note: Raw data files not included due to size (>400MB). Follow setup instructions to reproduce.

## Project Structure
```
sugar_alternative_whitespace_analysis/
├── scripts/
│   └── 01_process_usda_data.py
├── notebooks/
│   ├── 02_data_exploration.ipynb
│   ├── 03_KPI_calculation.ipynb
│   └── 05_final_opportunity_analysis.ipynb
├── excel/
│   └── 04_google_trends_collection.xlsx
├── sql/
│   └── sugar_alternative_analysis.sql
├── visualizations/
│   └── Sugar_Alternative_Whitespace_Analysis.twbx
├── data/processed/ (local only)
├── README.md
└── requirements.txt
```

## Contact

Anna Biloshevska  
[LinkedIn](https://linkedin.com/in/annabiloshevska) | [GitHub](https://github.com/annabiloshevska)
