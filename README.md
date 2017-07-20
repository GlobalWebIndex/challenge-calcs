# Challenge: Calculations

Hey folks,
welcome to our calculation challange. Our team is responsible for API which make various types of calculations over data. In challenge are data represented by respondents. Each respondent answered on options of questions. By their answers we are able to make analysis and create groups of samples (audiences) which have some character and over these groups make basic anlysis.

## Terms
* **question** - question which respondent is answer (eg. How old are you? How many children do you have? ....)
* **option** - each question have options to answer. Eg. question `What is your gender` will have 2 options `Male` and `Female`
* **respondent** - a single user who has answered a set of questions
* **audience** - think about it as it is sample of respondent over which the analysis is made. The audience can have some character. Eg. young users which are using iPhone. This character is represented by logical json expression `{and: [{age: [:young]}, {phone: [:iphone]}]`. The audience can be also simply universe (all respondents - no expression which filter respondents).

### Metrics
The analysis include calculated metrics.
* **percentage** - ratio of respondents related to datapoint in audience. *The number is rounded to 1 decimal place*.
* **responses_count** - count of respondents related to datapoint in audience
* **weighted** - sum of respondents weighting related to datapoint in audience.

## Simple example
### Analyse gender in our universe
Let say we have 5 respondents. Each respondent represent 100 people. From these 5 respondents are 3 women and 2 men. If we would want have simply analis which say us some metrics how many men and women we have at all (audience == universe == no filter expression) we should get these numbers:

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
By this we can say that 40% of our universe for analysis are male and the rest are women.

### Analyse gender for iPhone users
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
From this numbers we can say that 33.3% of iPhone users are male and 66.7% are female.

## Good to know
* ruby
* elasticsearch
* docker (in case you don't have ruby and elasticsearch installed on local)

## How to start
The challenge has 2 parts:
* Implement missing tests cases [here](https://github.com/GlobalWebIndex/challenge-calcs/blob/master/spec/calc_spec.rb#L99-L104).
* Implement missing logic in models, which makes tests green. One test is green which indicate some basic logic is working. Missing logic is:
  * calculate `weighted` and `percentage` metrics (hint: one more sum aggregation and common formula for percentage)
  * apply audience expression for make calculations only over specific sample (hint: filter)

For run tests you can use docker compose by executing `docker-compose run challenge`. If you don't want use docker and use `rspec` directly
please run it with `ELASTIC_URL` env variable set to your local elasticsearch instance.

If you are interested in applying for this position or just want to challenge yourself (which is also 100% OK for us) please continue in following steps:

* Fork this repository under your GitHub account.
* Complete implementation inside your fork.
* Open pull request to original repository with your own implementation which makes tests green. Also please feel free to design another structure on models or methods
level. The current logic is only scratch for push off.
* Comment your pull request with message containing READY or RDY to let us know that we can review your code.
* Comment your PR with any question in case you will need any help (or send us email - see bellow).

***__You can also open pull request before you're finished with implementation in case you are willing to discuss anything!__

# Contacts
In case you want to apply for position in our team please contact `petr@globalwebindex.net`. If you have any questions about implementation itself you can send mail to `zdenko@globalwebindex.net` or `roman@globalwebindex.net`. Also you can open an issue/PR in this repository so we can discuss any part together.
