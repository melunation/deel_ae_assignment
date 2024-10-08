# Deel Analytics Engineering Assignment

### Assignment description

#### Business Context
Deel clients can add funds to their Deel account using their credit and debit cards. Deel has
partnered with Globepay to process all of these account funding credit and debit card
transactions. Globepay is an industry-leading global payment processor and is able to process
payments in many currencies from cards domiciled in many countries.

Deel has connectivity into Globepay using their API. Deel clients provide their credit and
debit details within the Deel web application, Deel systems pass those credentials along with
any relevant transaction details to Globepay for processing.
Please see related files in the attached zip file.
Assignment
A Data Analyst at Deel has submitted a request for you to create a model to answer a few
questions about payments. Three files have been provided in the request (attached to this
document as files.zip) - however, no schema specifications were given.

### Solutions

#### Part 1
For the first part of the challenge, please ingest and model the source data — try following the
dbt modeling standards ⭐ .

##### 1. Preliminary data exploration
  We're working with Globepay API data, and based on the specifications html we can say that the API would actually return one table instead of two. So most likely these tables have been broken for the assignment in order to force a join to be performed. By ingesting the data and applying some basic tests, we can find some observations:
  - There are no nulls or duplicates in the primary (`ref`) or in the foreign keys (`external_ref`). 
  - We find 1 transaction in the acceptance source data that has an amount smaller than 0. This could be Deel refunding an amount to a client, an error in processing... since I do not know if this is acceptable from a business point of view, I have flagged this in tests as a warn so that dbt raises this when running.
  - All of the data is from 2019
    
##### 2. Summary of your model architecture
The designed architecture is pretty straightforward:
  1. Staging layer where we ingest the data (that has been loaded into our database using the `dbt seed` command, adding the csv files under the `seed` folder) and apply basic transformations to it. These can include castings to make sure our data is in the desired format, cleaning of columns that might have things we don't want, and operations to create new columns that will be used downstream. The models in here are `stg_acceptance` and `stg_chargeback`.
  3. Transforming layer where we apply the transformations needed to build the logic of our models. This can include joins and the use of more complex functions, as well as the addition of business logic. The model here is `trn_transformation`
  5. Datamart layer where we either expose the data we have created in transforming (in case there are no transformations being done, we can do it through a view to make sure we're not duplicating a table in the DWH). We can also create aggregations of the data existing in the transforming layer in a cube format, depending on the business requirements and the granularity of the data needed for reporting. The models here are `transactions_cube` and `transactions`. We materialize this last one as a view, since it is just a select all from the model in the transformation layer and we don't need it to occupy storage in our database.
##### 3. Lineage graphs
  This lineage has been created using commands `dbt docs generate` and `dbt docs serve`. In green we can see the seeds, where we added the csvs provided, and in blue we can see the models stated in the section above.
  <img width="1543" alt="image" src="https://github.com/user-attachments/assets/39d0434b-e8e8-4dfb-b5a7-aca4f5d477ef">

##### 4. Tips around macros, data validation, and documentation
  - Macros: Since this exercise was fairly simple in terms of available data, there was not the need to develop any macros. These should be created when a piece of code is going to be reused many times, which will allow us to just call the macro and not have to repeat that piece of code everywhere. It is also great since if we need to do some changes, updating the macro will update it everywhere (and if we didn't develop a macro we would have to change all of those instances one by one). Maybe we could have created a macro for the exchange rate if we had used a different approach, but it wasn't needed here.
  - Data validation: dbt offers powerful tests to validate the data we're dealing with. The basics here would be making sure that keys don't have nulls and are unique, which can be applied to any other field that requires it. We can also do other kinds of checks, like making sure an end date is after a start date, amounts are between a certain range, or the values of the column stay within the expected values. These tests allow for quick and easy data validation, and it makes much easier and quicker address and fix the potential issues.
  - Documentation: Documentation can be added as part of the yml file, which then can be exposed to some external tools to allow business to check definitions. This is a really important part of a good DWH since it will allow external people to it understand what each table and field is, and the transformations that have been done around it, without having to reach out to the creator of the model.
    
#### Part 2
For the second part of the challenge, please develop a production version of the model for the
Data Analyst to utilize. 

This model should be able to answer these three questions at a
minimum:
1. What is the acceptance rate over time?
2. List the countries where the amount of declined transactions went over $25M
3. Which transactions are missing chargeback data?
In addition to presenting the model, please provide the code (pseudo-code also suffices) for
answering these questions. Feel free to provide the code, the actual answers, a brief description
for the analyst, and any charts or images to help with the explanation.

#### Model being used
  Here, I would like to mention that even the requirement asks for one model, I think there are two different approaches that could work to answer the questions listed below. I think the preference to use one or the other would be different based on the requirements the Data Analyst has, so if this was my job I would discuss with him what he needs / prefers and provide the most ideal model based on this. The options would be:
  1. A non aggregated model with transaction granularity (one per row). Aggregations could be performed on top of this in the BI tool. This model would be `transactions` in the datamart layer.
  2. An aggregated model that is still able to answer the questions, like the one developed, `transactions_cube`, in the datamart layer.

  For this I am going to used the aggregated model, `transactions_cube`. This model aggregates the data at a daily and country level, allowing us to obtain all of the data we need at this granularity, as well as increasing the granularity to greater time dimensions if needed. For the acceptance rate, it is needed to have two columns so that we can aggregate: one with the number of accepted transactions and one with the number of rejected transactions. The model has the following columns:
  - date: Time dimension, at a day level
  - country: Country of the transaction
  - accepted_transactions: Number of transactions accepted in the day and country.
  - total_transactions: Total number of transactions, accepted or rejected, in the day and country.
  - total_usd_amount_accepted: Total USD amount of the accepted transactions.
  - total_usd_amount_declined: Total USD amount of the declined transactions.
  - total_usd_amount: Total USD amount of all the transactions.
  - transactions_without_chargeback: Array containing the ref of the transactions that had `chargeback = false` in that day and country.
  - unique_key: Key created through dbt to ensure uniqueness of the desired granularity.
  <img width="1246" alt="image" src="https://github.com/user-attachments/assets/1add2f64-fa75-47eb-8658-b16dde3a9766">


##### 1. What is the acceptance rate over time?
  The acceptance rate can be calculated at any time dimension (day, week, month, quarter, year) since we have the lowest date granularity (day) and we can aggregate by summing the accepted transactions and divide it by the sum of the total transactions. It would not be possible to offer a direct acceptance result at the daily level because then aggregation would not be possible at higher levels.
  ```
    select
      date_trunc('year',date) as date,
      sum(accepted_transactions) / sum(total_transactions) as acceptance_rate
    from transactions_cube
    group by 1
  ```
  The answer would depend on the granularity of the business requirement, but if we look at it at a yearly level the result would be a 69.56% acceptance rate
  <img width="330" alt="image" src="https://github.com/user-attachments/assets/b4d7ad38-641d-4e23-9328-5253894efb9b">

##### 2. List the countries where the amount of declined transactions went over $25M
  We just select distinct countries where the sum of the declined transactions amount is over 25M. We can do this directly using a having clause
```
    select distinct
      country
    from transactions_cube
    group by 1
    having sum(total_usd_amount_declined) > 25000000
  ```
  The countries are:
<img width="165" alt="image" src="https://github.com/user-attachments/assets/ff6a2494-dedb-4ffc-88d8-93858dd7c82e">

##### 3. Which transactions are missing chargeback data?
  There's two ways to understand this: 
    1. "missing chargeback data" means that there is no chargeback data available for that transaction (meaning the acceptance table would not find a match in the chargeback table when joining)
    2. The transaction has chargeback = false. 
    
  Since I explored the data and saw that all of the transactions join with the data in chargeback, I will assume the question being asked is the second one: number of transactions with chargeback data = false.
  
  In this case the analyst could just select the column `transactions_without_chargeback` and flatten it to get a list of the transaction refs that did not have chargeback data (using the aggregated model)
  If the analyst preference and/or the business requirements would be to not have an aggregated table, selecting the ref column where chargeback is not true would be enough to get this answer.
  Of course time dimensions can be added to filter the transactions without chargeback in a specific time frame.

