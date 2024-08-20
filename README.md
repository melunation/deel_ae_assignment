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
1. Please include a document with information around:
1. Preliminary data exploration
2. Summary of your model architecture
3. Lineage graphs
4. Tips around macros, data validation, and documentation

Part 2
For the second part of the challenge, please develop a production version of the model for the
Data Analyst to utilize. This model should be able to answer these three questions at a
minimum:
1. What is the acceptance rate over time?
2. List the countries where the amount of declined transactions went over $25M
3. Which transactions are missing chargeback data?
In addition to presenting the model, please provide the code (pseudo-code also suffices) for
answering these questions. Feel free to provide the code, the actual answers, a brief description
for the analyst, and any charts or images to help with the explanation.

