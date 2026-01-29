import pandas as pd

print("Step 1: Loading branded_food.csv...")
df_branded = pd.read_csv('branded_food.csv', low_memory=False)
print(f"Loaded {len(df_branded):,} branded products")

print("\nStep 2: Loading food.csv...")
df_food = pd.read_csv('food.csv', low_memory=False)
print(f"Loaded {len(df_food):,} food records")

print("\nStep 3: Loading food_nutrient.csv (this takes 1-2 min)...")
df_nutrients = pd.read_csv('food_nutrient.csv', low_memory=False)
print(f"Loaded {len(df_nutrients):,} nutrient records")

print("\nStep 4: Extracting sugar, protein, fat...")
nutrients_needed = [2000, 1003, 1004]  # Sugar, Protein, Fat
df_nut_filtered = df_nutrients[df_nutrients['nutrient_id'].isin(nutrients_needed)]

df_nut_wide = df_nut_filtered.pivot_table(
    index='fdc_id', 
    columns='nutrient_id', 
    values='amount', 
    aggfunc='first'
).reset_index()

df_nut_wide.columns = ['fdc_id', 'fat_100g', 'protein_100g', 'sugar_100g']
print(f"Processed nutrients for {len(df_nut_wide):,} products")

print("\nStep 5: Merging datasets...")
df_merged = df_branded.merge(df_food[['fdc_id', 'description']], on='fdc_id', how='left')
df_final = df_merged.merge(df_nut_wide, on='fdc_id', how='left')
print(f"Merged dataset: {len(df_final):,} products")

print("\nStep 6: Filtering to US market with complete data...")
df_us = df_final[
    (df_final['market_country'] == 'United States') &
    (df_final['sugar_100g'].notna()) &
    (df_final['sugar_100g'] >= 0) &
    (df_final['sugar_100g'] <= 100) &
    (df_final['branded_food_category'].notna()) &
    (df_final['ingredients'].notna())
].copy()

print(f"\nFinal US products: {len(df_us):,}")

print("\nStep 7: Saving to CSV...")
df_us.to_csv('us_products_clean.csv', index=False)

import os
file_size = os.path.getsize('us_products_clean.csv') / (1024**2)
print(f"\nSaved: us_products_clean.csv ({file_size:.1f} MB)")

# Creating a stratified sample (proportional from each category)
print("\nCreating 50K sample (stratified by category)...")

sample_size = 50000
df_sample = df.groupby('branded_food_category', group_keys=False).apply(
    lambda x: x.sample(n=min(len(x), int(sample_size * len(x) / len(df))), random_state=42)
)

print(f"Sample size: {len(df_sample):,} products")
print(f"Categories: {df_sample['branded_food_category'].nunique()}")

# Saving sample
df_sample.to_csv('us_products_sample_50k.csv', index=False)

import os
size = os.path.getsize('us_products_sample_50k.csv') / (1024**2)
print(f"\nSaved: us_products_sample_50k.csv ({size:.1f} MB)")