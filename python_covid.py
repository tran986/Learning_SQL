import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

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

print(national_daily.head(5))
print(monthly.head(5))
#Compute the month-over-month absolute change and % change.
national_daily["mom_change"]=national_daily["deathIncrease"].diff()
national_daily["mom_pct"]=national_daily["deathIncrease"].pct_change()
national_daily.rename(columns = {"deathIncrease":"total_deaths"})
#Display as a clean table with columns: month, total_deaths, mom_change, mom_pct.
national_daily=national_daily.dropna(how = "any",
                            axis = 0)

#print(national_daily.columns)

## Q13. For each state, find the peak (maximum) value of hospitalizedCurrently.
#Rank states 1–N (1 = highest). Add the date on which the peak occurred.
#Display the top 10 states with columns: state, peak_hosp, peak_date, rank.
q13_covid=covid_db.dropna(subset=["hospitalizedCurrently"])
q13_covid_rank=q13_covid.groupby("state")["hospitalizedCurrently"].idxmax().head(10).tolist()
q13_fin=covid_db.iloc[q13_covid_rank][["state","hospitalizedCurrently","date"]]
q13_fin=q13_fin.rename(columns={"hospitalizedCurrently":"peak_hos",
                        "date":"peak_date"})
q13_fin=q13_fin.sort_values(by="peak_hos", ascending = False)
q13_fin["rank"]=q13_fin["peak_hos"].rank(ascending = False)

## Q14. Create a pivot table where:
#rows = state
#columns = month (Jan 2020 … Mar 2021)
#values = sum of positiveIncrease
#Fill missing values with 0. Show only states where total > 500,000 cases.
#print(covid_db.columns)
covid_db["date"]=pd.to_datetime(covid_db["date"])
covid_db["month"]=covid_db["date"].dt.to_period("M")
pivot_covid=pd.pivot_table(covid_db, values="positiveIncrease", index=["state"], 
                     columns=["month"], aggfunc=np.sum)
pivot_covid=pivot_covid.fillna(0)
pivot_covid=pivot_covid.loc[(pivot_covid > 500000).any(axis=1), :]
print(pivot_covid.head(5))
print(pivot_covid.columns)

## Q15. Compute the Case Fatality Rate per state as:
#CFR = (max cumulative death / max cumulative positive) * 100
#Exclude states where max positive < 10,000 (too small for meaningful CFR).
#Display top 10 and bottom 10 states by CFR. 
print(covid_db.columns)
max_death = covid_db.groupby("state")["deathIncrease"].max()
max_pos = covid_db.groupby("state")["positiveIncrease"].max()
cfr=(max_death / max_pos) * 100
cfr_merge=pd.concat([cfr, max_death, max_pos], axis = 1)
cfr_merge.rename(columns = {cfr_merge.columns[0]:"cfr"},
                 inplace = True)
cfr_merge_clean=cfr_merge.fillna(0)
cfr_merge_clean=cfr_merge_clean[cfr_merge_clean.iloc[:, ] >= 10000]

## Q16. Compute daily ICU occupancy as:
#icu_rate = inIcuCurrently / hospitalizedCurrently * 100
#For each state, compute the median ICU rate over all available dates.
#Identify the 5 states with the highest and lowest median ICU rates.
#Exclude states with fewer than 30 non-null data points for inIcuCurrently.
icu_cal = lambda x, y: x/y*100
covid_db["icu_rate"]=icu_cal(covid_db["inIcuCurrently"], 
        covid_db["hospitalizedCurrently"])
median_icu=covid_db.groupby("state")["icu_rate"].median().reset_index()
median_icu=median_icu.sort_values(by="icu_rate", ascending = False)
print(median_icu.head(5))
covid_db=covid_db.fillna(0, inplace = True) #fix NA
print(median_icu.tail(5))

## Q17. Plot the national daily new cases (sum of positiveIncrease across all states) over time.
#Overlay a 7-day rolling average line.
#Label axes and add a title. Use a vertical line to mark 2021-01-01.
#Save as "q17_national_cases.png" at 150 dpi.
national_new_case=covid_db.groupby("date")["positiveIncrease"].sum().reset_index()
print(national_new_case.head(5))
national_new_case["date"]=pd.to_datetime(national_new_case["date"]) #convert to daytime:
national_new_case["7_day_rolling"]=covid_db.groupby("date")["positiveIncrease"].rolling(window = 7).mean().reset_index(level=0, drop=True)

plt.figure(figsize=(14, 6))
plt.plot(national_new_case["date"], 
         national_new_case["positiveIncrease"], 
         color = "red", 
         linewidth=1.5)
plt.plot(national_new_case["date"],
            national_new_case["7_day_rolling"], 
            color='blue', 
            linestyle='--', 
            linewidth=1, 
            label='axvline (behind)', 
            zorder=0)
line_position=national_new_case[national_new_case["date"] == pd.Timestamp("2021-01-01")]
plt.vlines(line_position["date"], 
           ymin=1, 
           ymax=national_new_case["positiveIncrease"].max(),
           colors='purple', 
           linestyles='solid')
plt.title("National Daily New Cases Over Time")
plt.xlabel("Date")
plt.ylabel("New Case")
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()
#plt.savefig('/Users/tran.986/Desktop/Learning_SQL/national_daily_case_overtime.png', dpi=150, bbox_inches="tight") 

## Q18. Plot cumulative positive cases over time for these 6 states on one figure:
#CA, TX, NY
#Use a different colour per state. Add a legend.
#X-axis: date, Y-axis: cumulative positive cases (in millions).

q18=covid_db[["date","positiveIncrease","state"]]
q18=q18[q18["state"].isin(["CA","TX", "NY", "PA", "OH", "FL", "IL"])]
q18["positiveIncrease_millions"]=q18["positiveIncrease"]/1000000
q18_per_state=q18.groupby(["state","date"])["positiveIncrease_millions"].sum().reset_index()
q18_per_state["date"]=pd.to_datetime(q18_per_state["date"])
plt.figure(figsize=(14, 6))
for state, group in q18_per_state.groupby("state"):
    plt.plot(group["date"], group["positiveIncrease_millions"], linewidth=1, label=state)

plt.title("Positive Case Over Time CA, TX, NY, PA, OH, FL, IL")
plt.legend(bbox_to_anchor=(1.01, 1), loc="upper left", fontsize=7, ncol=2)
plt.xlabel("Date")
plt.ylabel("Case (millions)")
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()
plt.savefig('/Users/tran.986/Desktop/Learning_SQL/positive_overtime_some_states.png', dpi=150, bbox_inches="tight") 

