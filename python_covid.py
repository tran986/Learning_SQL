import pandas as pd
import numpy as np

covid_db = pd.read_csv("/Users/tran.986/Downloads/all-states-history.csv")


## SECTION 1:
#Q1  - Print the first 10 rows
print(covid_db.head(10))
#  - Print the shape (rows × columns)
print(covid_db.shape)
#  - Print all column names
print(covid_db.columns)
#  - Print the data types of each column
print(type(covid_db))

#Q2: - For every column, calculate:
#  - The count of missing values
print(covid_db.isnull().sum())
#  - The percentage of missing values (rounded to 1 decimal place)
print((covid_db.isnull().sum()*100/len(covid_db)).round(2).sort_values(ascending=False))
# Sort the result descending by percentage missing and display it as a clean DataFrame.
clean_df=(covid_db.isnull().sum()*100/len(covid_db)).round(2).sort_values(ascending=False)
print(clean_df.head(10)) # len returns number of rows

#Q3. The "date" column is loaded as a string. Convert it to datetime64.
covid_db['date_mod']=pd.to_datetime(covid_db['date'])

#Then extract and add three new columns:
#  - year (int)
#  - month (int)
#  - day_of_week  (0=Monday … 6=Sunday)
covid_db["year"] = covid_db.date_mod.dt.year
covid_db["month"] = covid_db.date_mod.dt.month
covid_db["day"] = covid_db.date_mod.dt.day

#print(covid_db.month.head(5))
#print(covid_db.month)

#Confirm the dtype of "date" after conversion.
print(type(covid_db.day))

## Q4. Produce a descriptive statistics table for these four columns:
#positive, death, hospitalizedCurrently, totalTestResults
#Include: count, mean, std, min, 25%, 50%, 75%, max.
#Round all values to 2 decimal places.
q4_covid=covid_db[["positive","death","hospitalizedCurrently","totalTestResults"]]
print(q4_covid.sum())
print(q4_covid.mean())
print(q4_covid.std())
print(q4_covid.min())
print(q4_covid.max())
print(q4_covid.quantile(0.25).round(2))
print(q4_covid.quantile(0.5).round(2))
print(q4_covid.quantile(0.75).round(2))

## Q5. Filter the dataset to keep only rows for California (state == "CA").
#Sort by date ascending. Reset the index.
#Print the first 5 and last 5 rows of the result.
ca_covid=covid_db[covid_db["state"] == "CA"].sort_values(by="date", ascending=True).reset_index(drop = True)
print(ca_covid.iloc[0:5, 0:5])

## Q6. Count how many rows (dates) exist per state.
#Display the result sorted descending.
#Which states have fewer than 100 records?

print(covid_db.state.unique())
print(covid_db.groupby("state").size().sort_index(ascending=False))
print(covid_db.groupby("state").filter(lambda x:len(x)< 100).state.unique())

## Q7. Create a tidy subset DataFrame with only these columns, renamed as shown:
#date → date
#state → state
#positive → total_cases
#death → total_deaths
#hospitalizedCurrently → hosp_current
#totalTestResults → total_tests
tidy_db=covid_db[["state","date","totalTestResults","hospitalizedCurrently","death","positive"]]
tidy_db=tidy_db.rename(columns={"death":"total_deaths",
                        "totalTestResults":"total_res",
                        "positive":"total_cases",
                        "hospitalizedCurrently":"hosp_current"})


#Drop any rows where all four numeric columns are NaN simultaneously.
tidy_db=tidy_db.dropna(subset = ["total_res","hosp_current","total_deaths","total_cases"])
print(tidy_db.head)

## Q8. Using the tidy subset from Q7 (or re-derive), compute:
#positivity_rate = positiveIncrease / totalTestResultsIncrease * 100
tidy_db["positivity_rate"] = covid_db["positiveIncrease"] / covid_db["totalTestResultsIncrease"] * 100

#Handle division by zero (where totalTestResultsIncrease == 0) by assigning NaN.
tidy_db["positivity_rate"] = tidy_db["positivity_rate"].fillna(0)
tidy_db["positivity_rate"] = tidy_db["positivity_rate"].replace([np.inf, -np.inf], np.nan)

#Print the min, mean, median, and max of positivity_rate, ignoring NaN.
print(tidy_db["positivity_rate"].max())
print(tidy_db["positivity_rate"].min())
print(tidy_db["positivity_rate"].median())

## Q9. For each state, find the maximum cumulative death count
#(the "death" column represents cumulative deaths — its max per state ≈ total deaths).
#Sort descending and display the top 15 states.
print(covid_db.groupby("state")["death"].sum().sort_index(ascending=False).head(15))

# Q10. Aggregate across all states by date to get national daily totals for:
#positiveIncrease, deathIncrease, hospitalizedIncrease, totalTestResultsIncrease
#Sort by date. Print the row with the highest single-day positiveIncrease nationally.
print(covid_db.groupby("date")["positiveIncrease"].mean())
print(covid_db.groupby("date")["deathIncrease"].mean())
print(covid_db.groupby("date")["totalTestResultsIncrease"].mean())

# Q11. For California only, compute a 7-day rolling average of positiveIncrease.
#Add it as a new column "rolling_7d_cases".
#Also compute a 14-day rolling average "rolling_14d_cases".
#Print the first row where the 7-day average exceeds 30,000.
ca_covid["rolling_7d_cases"]=ca_covid.groupby("state")["positiveIncrease"].rolling(window = 7).mean().reset_index(level=0, drop=True)
ca_covid["rolling_14d_cases"]=ca_covid.groupby("state")["positiveIncrease"].rolling(window = 14).mean().reset_index(level=0, drop=True)
print(ca_covid[ca_covid["rolling_7d_cases"] > 30000].head(5))

## Q12. For the national daily totals (sum across states), resample by month to get total deathIncrease per month.
national_daily=covid_db.groupby("date")["deathIncrease"].sum().reset_index()
print(national_daily.head(5))
national_daily["date"] = pd.to_datetime(national_daily["date"])
national_daily=national_daily.set_index("date")
monthly=national_daily["deathIncrease"].resample("ME").sum().reset_index()

#Compute the month-over-month absolute change and % change.
#Display as a clean table with columns: month, total_deaths, mom_change, mom_pct.

