# Challenge: Calculations

Hey folks,
welcome to our calculation challenge. Our team is responsible for API which makes various types of calculations over data. In challenge are data represented by respondents. Each respondent answered on options of questions. By their answers, we are able to make analysis and create groups of samples (audiences) which have some character and over these groups make a basic analysis.

## Terms
* **question** - question which respondent is answer (eg. How old are you? How many children do you have? ....)
* **option** - each question has options to answer. Eg. question `What is your gender` will have 2 options `Male` and `Female`
* **respondent** - a single user who has answered a set of questions
* **audience** - think about it as it is a sample of respondents over which the analysis is made. The audience can have some character. Eg. young users which are using iPhone. This character is represented by logical JSON expression `{and: [{age: [:young]}, {phone: [:iphone]}]`. The audience can be also universe (all respondents - no expression which filters respondents).

### Metrics
The analysis include calculated metrics.

* **percentage** - the ratio of respondents related to the data point in the audience. *The number is rounded to 1 decimal place*.
* **responses_count** - the count of respondents related to the data point in audience
* **weighted** - the sum of respondents weighting related to the data point in the audience.

## Simple example
### Analyze gender in our universe
Let say we have 5 respondents. Each respondent represents 100 people. From these 5 respondents are 3 women and 2 men. If we would want to have simply analysis which let's say some metrics how many men and women we have at all (audience == universe == no filter expression) we should get these numbers:

```javascript
{
  option: 'male',
  responses_count: 2,
  weighted: 200,
  percentage: 40
},
{
  option: 'female',
  responses_count: 3,
  weighted: 300,
  percentage: 60
}
```
By this, we can say that 40% of our universe for analysis are male and the rest are women.

### Analyze gender for iPhone users
If we would say we want to make analysis over respondents which are using iPhone we would go in next steps.
* filter respondent which are answered they are using iPhone
* calculate metrics for these respondents.

So if we say from our sample are 2 women and 1 man using iPhone we should get these numbers for required audience.
```javascript
{
  option: 'male',
  responses_count: 1,
  weighted: 100,
  percentage: 33.3
},
{
  option: 'female',
  responses_count: 2,
  weighted: 200,
  percentage: 66.7
}
```
From this numbers we can say that 33.3% of iPhone users are male and 77.7% are female.

# How to start
# Contacts
In case you want to apply for the position in our team please contact petr@globalwebindex.net. If you have any questions about implementation itself you can send an email to zdenko@globalwebindex.net or roman@globalwebindex.net. Also, you can open an issue/PR in this repository so we can discuss any part together.
