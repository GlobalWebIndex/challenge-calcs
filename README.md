# Challenge: Calculations

Hey folks,
welcome to our calculation challenge. Our team is responsible for the API which makes various types of calculations over the GWI dataset. In our challenge, data are represented by respondents. A respondent answers each question by selecting one or more options. (e.g. Selecting ‘Female’ when asked ‘what gender are you?’ or selecting ‘music’, ‘gaming’ and ‘cooking’ when asked ‘What are your interests?’. Each respondent is given a weighting so all respondents together represent the total internet population of a country. Based on the responses we can answer basic questions like “How many respondents are female?”  but we are able to combine data points together and profile them into groups (audiences) with same or similar characteristics and make a basic analysis. (e.g. we may make an audience of those interested in gaming or music then ask more complex questions like “How many women are interested in gaming or music?”)

## Vocabulary
* **respondent** - A single user who has answered a set of questions in our surveys.
* **question** - A question which respondent is asked in our surveys (eg. How old are you? How many children do you have? ...)
* **option** - Each question has many options to answer. For instance question `What is your gender` will have 2 options `Male` and `Female`.
* **universe** - All respondents who took our survey.
* **audience** - Think about it as it's a sample of respondents over which the analysis is made. The audience can have some characteristic. Let's say that from all respondents (universe) you're interested only in young users which are using iPhone. This characteristic is represented by logical JSON expression `{must: [{age: [:young]}, {phone: [:iphone]}]` which is used to filter respondents we want for our analysis. Even universe can be audience - you just don't apply any expression which filters respondents.
* **weighting** - Because we can't ask everybody on planet, each respondent is given some weighting (e.g. they represent 1,000 people) in our data set so when all respondents are combined their weighting sums to the total internet populations and is representative across demographic characteristics.

### Metrics
The analysis include calculated metrics.

* **percentage** - the ratio of respondents related to the option in the audience. *The number is rounded to 2 decimal places*.
* **responses_count** - the count of respondents related to the option in the audience
* **weighted** - the sum of respondents weighting related to the option in the audience.

### Audience expression
Audience expression is used as filter for respondent sample. By this expression we are describing the sample over which we are making calculations. As we can see
in test the expression has JSON format. So for example expression like this: `{must: [{gender: [:male]}, {age: [:young]}]}` are saying we are interested in **Young men** sample/audince.

Also the expression could be nested (doesn't need to be only one level `and` or `or` array in JSON). The expression could look like this:
`{must: [{question1: [option1]}, {should: [{question2: [option2]}, {question3: [option3, option4]}]}]}`. The grammar below is describing the structure.

```
E -> AND | OR | q
AND -> { must: Array<E> }
OR -> { should: Array<E> }
q -> { question_code: Array<question_option> }
```

## Examples
### 1. Analyze gender in our universe
Let say we have 5 respondents we asked in our survey. Each respondent represents 100 people which is his weighting. From these 5 respondents there are 3 women and 2 men.
If we would want to have simple analysis which tell us how many men and women we have at all (audience == universe == no filter expression) we should get these numbers:

```javascript
// audience: universe, question: gender
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

We can say that 40% of our universe for analysis are men and the rest are women.

#### 1.1. Why do we have weightings?
Example above was really simple example where each respondent represents same number of people (weightings are narrowed). You could see that we don't have data that represents reality cause from statistics we know that in population the gender ratio is closer to 50:50 than 40:60 in our example.

What would happen if we'd say that each of our male respondent will have a bigger weighting - let's say 140?

```javascript
// audience: universe, question: gender
{
  option: 'male',
  responses_count: 2,
  weighted: 280,
  percentage: 48.28
},
{
  option: 'female',
  responses_count: 3,
  weighted: 300,
  percentage: 51.72
}
```

Now we can say that our 2 men represents 280 men in population and our 3 women represents 300 women in the population of 580 people.
This in other words means that 48.28% of our universe for analysis are men and the rest are women which is much closer to 50:50 gender ratio in actual world population.
You can see that by using a little adjustment in weightings can get closer to reality and get more accurate results.

### 2. Analyze gender for iPhone users
If we would say we want to make analysis over respondents who are using iPhone we would take next steps:
* filter respondent who answered they are using iPhone
* calculate metrics only for these respondents.

So if we say from our sample 2 women and 1 man (with same weightings) are using iPhone we should get following results for our audience.

```javascript
// audience: iPhone users, question: gender
{
  option: 'male',
  responses_count: 1,
  weighted: 100,
  percentage: 33.33
},
{
  option: 'female',
  responses_count: 2,
  weighted: 200,
  percentage: 66.67
}
```
From these numbers, we can say that 33.3% of iPhone users are male and 66.7% are female.

### 3. Analyzing different audiences
What would be percentage of men who are using iPhone and what would be percentage of women using iPhone? Consider that those people who didn't answered iPhone they answered Samsung.
How could we run these kind of analysis?

We'll be again using different weightings per gender from example 1.1. We need to create two audiences - male and female.

```javascript
// audience: male, question: phone
{
  option: 'iphone',
  responses_count: 1,
  weighted: 140,
  percentage: 50
},
{
  option: 'samsung',
  responses_count: 1,
  weighted: 140,
  percentage: 50
}
```

```javascript
// audience: female, question: phone
{
  option: 'iphone',
  responses_count: 2,
  weighted: 200,
  percentage: 66.67
},
{
  option: 'samsung',
  responses_count: 1,
  weighted: 100,
  percentage: 33.33
}
```

We can say that 50% of men and 66.67% of women uses an iPhone.

## Good to know
* ruby
* elasticsearch
* docker (in case you don't have ruby and elasticsearch installed on local)

## How to start
The challenge has 2 parts:
* Implement the missing tests cases [here](https://github.com/GlobalWebIndex/challenge-calcs/blob/master/spec/calc_spec.rb#L99-L104).
* Implement the missing logic in models, which makes tests green. One test is green, which indicate some basic logic is working. Missing logic is:
  * calculate `weighted` and `percentage` metrics
  * apply audience expression to make calculations only over specific sample

To run tests you can use docker compose by executing `docker-compose run challenge`. If you don't want use docker and use `rspec` directly
please run it with `ELASTIC_URL` env variable set to your local elasticsearch instance.

If you are interested in applying for this position or just want to challenge yourself (which is also 100% OK for us) please continue in following steps:

* Create new private repository under your GitHub or Bitbucket account and import there code from this repository (so that you don't share your solution with other candidates).
* Complete implementation inside your repo and invite us for review (GH user names: `zdenal`, `romansklenar`).
* Open pull request in your repository with your own implementation which makes tests green. Also please feel free to design another structure on class or methods
level. The current logic is only scratch for push off.
* Comment your pull request with a message letting us know that we can review your code.
* Comment your PR with questions in case you need any help (or send us email - see bellow).

***__You can also open pull request before you're finished with implementation in case you are willing to discuss anything!__***

# Contacts
If you would like to apply for the position in our team, please contact `petr@globalwebindex.net`. If you have any questions about implementation itself, you can send mail to `zdenko@globalwebindex.net` or `roman@globalwebindex.net`. Also you can open an issue/PR in this repository so we can discuss any part together.
