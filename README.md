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
  We're working with Globepay API data, and based on the specifications html we can say that the API would actually return both tables into one. So most likely these tables have been broken for the assignment in order to force a join to be performed.
By ingesting the data and applying some basic tests, we can confirm that there are no nulls or duplicates in the primary (`ref`) or in the foreign keys (`external_ref`). As an interesting catch, we find 1 transaction in the acceptance source data that has an amount smaller than 0. This could be Deel refunding an amount to a client, an error in processing...
##### 2. Summary of your model architecture
The designed architecture is pretty straightforward:
  1. Staging layer where we ingest the data (that has been loaded into our database using the `dbt seed` command, adding the csv files under the `seed` folder) and apply basic transformations to it. These can include castings to make sure our data is in the desired format, cleaning of columns that might have things we don't want, and operations to create new columns that will be used downstream. The models in here are:
    a. `stg_acceptance`
    b. `stg_chargeback`
  3. Transforming layer where we apply the transformations needed to build the logic of our models. This can include joins and the use of more complex functions, as well as the addition of business logic. The model here is:
    a. `trn_transformation`
  5. Datamart layer where we either expose the data we have created in transforming (in case there are no transformations being done, we can do it through a view to make sure we're not duplicating a table in the DWH). We can also create aggregations of the data existing in the transforming layer in a cube format, depending on the business requirements and the granularity of the data needed for reporting. The models here are:
    a. `transactions_cube`
    b. `transactions`
##### 3. Lineage graphs
  This lineage has been created using commands `dbt docs generate` and `dbt docs serve`. In green we can see the seeds, where we added the csvs provided, and in blue we can see the models stated in the section above.
  <img width="1625" alt="image" src="https://github.com/user-attachments/assets/6574479c-4826-48e2-8807-ac0ad3393ac9">

##### 4. Tips around macros, data validation, and documentation
  - Macros: Since this exercise was fairly simple in terms of available data, there was not the need to develop any macros. These should be created when a piece of code is going to be reused many times, which will allow us to just call the macro and not have to repeat that piece of code everywhere. It is also great since if we need to do some changes, updating the macro will update it everywhere (and if we didn't develop a macro we would have to change all of those instances one by one). Maybe we could have created a macro for the exchange rate if we had used a different approach, but it wasn't needed here.
  - Data validation: dbt offers powerful tests to validate the data we're dealing with. The basics here would be making sure that keys don't have nulls and are unique, which can be applied to any other field that requires it. We can also do other kinds of checks, like making sure an end date is after a start date, amounts are between a certain range, or the values of the column stay within the expected values. These tests allow for quick and easy data validation, and it makes much easier and quicker address and fix the potential issues.
  - Documentation: Documentation can be added as part of the yml file, which then can be exposed to some external tools to allow business to check definitions. This is a really important part of a good DWH since it will allow external people to it understand what each table and field is, and the transformations that have been done around it, without having to reach out to the creator of the model.
#### Part 2
For the second part of the challenge, please develop a production version of the model for the
Data Analyst to utilize. 

#### Here, I would like to mention that even the requirement asks for one model, I have developed two to show two different approaches that could work for this problem. I think the preference to use one or the other would be different based on the requirements the Data Analyst has, so if this was my job I would discuss with him what he needs / prefers and provide the most ideal model based on this.

This model should be able to answer these three questions at a
minimum:
1. What is the acceptance rate over time?
2. List the countries where the amount of declined transactions went over $25M
3. Which transactions are missing chargeback data?
In addition to presenting the model, please provide the code (pseudo-code also suffices) for
answering these questions. Feel free to provide the code, the actual answers, a brief description
for the analyst, and any charts or images to help with the explanation.

##### 1. What is the acceptance rate over time?
  The acceptance rate can be calculated at any time dimension (day, week, month, quarter, year) since we have the lowest date granularity (day) and we can aggregate by summing the accepted transactions and divide it by the sum of the total transactions. It would not be possible to offer a direct acceptance result at the daily level because then aggregation would not be possible at higher levels.
  ```
    select
      date,
      sum(accepted_transactions) / sum(total_transactions)
    from transactions_cube
    group by 1
  ```
##### 2. List the countries where the amount of declined transactions went over $25M
  We just select distinct countries where the sum of the declined transactions amount is over 25M. We can do this directly using a having clause
```
    select distinct
      country
    from transactions_cube
    group by 1
    having sum(total_usd_amount_declined) > 25000000
  ```
##### 3. Which transactions are missing chargeback data?
  There's two ways to understand this: either "missing chargeback data" means that there is no chargeback data available for that transaction (meaning the acceptance table would not find a match in the chargeback table when joining), or that the transaction has chargeback = false. Since I explored the data and saw that all of the transactions join with the data in chargeback, I will assume the question being asked is the second one: number of transactions with chargeback data = false.
  In this case the analyst could just select the column `transactions_without_chargeback` and flatten it to get a list of the transaction refs that did not have chargeback data.

