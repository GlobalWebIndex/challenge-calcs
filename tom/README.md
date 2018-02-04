# Tom's Notes

- Elastic Search in v2.3.5 so some things may not be available
- [ES 2.3.5 reference](https://www.elastic.co/guide/en/elasticsearch/reference/2.3/query-dsl-bool-query.html)

## Findings

- `question` affects aggregation, it determines what the bucket keys will be
- `audience` affects collection, it determines what subset of the documents the aggregation will compute over

## Prototyping the cases

[Elastic Search Playground](https://www.found.no/play)

Documents:

```yaml
id: john
weighing: 1100
gender: male
age: young
color: red
---
id: peter
weighing: 1100
gender: male
age: old
color: red
---
id: steve
weighing: 1100
gender: male
age: middle
color: blue
---
id: rachel
weighing: 1000
gender: female
age: young
color: blue
---
id: susan
weighing: 1000
gender: female
age: old
color: red
---
id: kate
weighing: 1000
gender: female
age: middle
color: blue
```

Searches: see the cases.

## Case 1: `gender question` -> `has correct responses count for male`, `should return correct result`

- `question`: `gender`
- `audience`: `{}`
  - `male`
    - John
    - Peter
    - Steve
  - `female`
    - Rachel
    - Susan
    - Kate

```json
{
    "size": 0,
    "aggs": {
        "weighed_universe": {
            "sum": {
                "field": "weighing"
            }
        },
        "options": {
            "terms": {
                "field": "gender"
            },
            "aggs": {
                "weighed": {
                    "sum": {
                        "field": "weighing"
                    }
                }
            }
        }
    }
}
```

## Case 2: `gender question` -> `with red likers audience` -> `should return correct result`

- `question`: `gender`
- `audience`: `red_likers_audience` -> `{and: [{colour: [:red]}]}`
  - `male`
    - John
    - Peter
  - `female`
    - Susan

```json
{
    "size": 0,
    "query": {
        "filtered": {
            "filter": {
                "and": [
                    {
                        "term": {
                            "color": "red"
                        }
                    }
                ]
            }
        }
    },
    "aggs": {
        "weighed_universe": {
            "sum": {
                "field": "weighing"
            }
        },
        "options": {
            "terms": {
                "field": "gender"
            },
            "aggs": {
                "weighed": {
                    "sum": {
                        "field": "weighing"
                    }
                }
            }
        }
    }
}
```

## Case 3: `gender question` -> `with red and blue likers audience` -> `should return correct result`

- `question`: `gender`
- `audience`: `red_and_blue_audience` -> `{and: [{colour: [:red]}, {colour: [:blue]}]}`
  - No buckets

**The result should be empty, because we do not support liking multiple colors at the same time!**

```json
{
    "size": 0,
    "query": {
        "filtered": {
            "filter": {
                "and": [
                    {
                        "term": {
                            "color": "red"
                        }
                    },
                    {
                        "term": {
                            "color": "blue"
                        }
                    }
                ]
            }
        }
    },
    "aggs": {
        "weighed_universe": {
            "sum": {
                "field": "weighing"
            }
        },
        "options": {
            "terms": {
                "field": "gender"
            },
            "aggs": {
                "weighed": {
                    "sum": {
                        "field": "weighing"
                    }
                }
            }
        }
    }
}
```

## Case 4: `colour question` -> `has correct responses count for red`

- `question`: `colour`
- `audience`: `{}`
  - `red`
    - John
    - Peter
    - Susan

```json
{
    "size": 0,
    "aggs": {
        "weighed_universe": {
            "sum": {
                "field": "weighing"
            }
        },
        "options": {
            "terms": {
                "field": "color"
            },
            "aggs": {
                "weighed": {
                    "sum": {
                        "field": "weighing"
                    }
                }
            }
        }
    }
}
```

## Case 5: `colour question` -> `with female or not old audience` -> `should return correct result`

- `question`: `colour`
- `audience`: `female_or_not_old_audience` -> `{or: [{gender: [:female]}, {age: [:young, :middle]}]}`
  - `red`
    - John
    - Susan
  - `blue`
    - Steve
    - Rachel
    - Kate

```yaml
size: 0
query:
    filtered:
        filter:
            or:
            - term:
                gender:
                    female
            - and:
                - terms:
                    age:
                        - young
                        - middle

aggs:
    weighed_universe:
        sum:
            field: weighing
    options:
        terms:
            field: color
        aggs:
            weighed:
                sum:
                    field: weighing
```

## Case 6: `colour question` -> `with female || (red && old) audience` -> `should return correct result`

- `question`: `colour`
- `audience`: `female_or_red_old_audience` -> `{or: [{gender: [:female], {and: [{colour: [:red]}, {age: [:old]}]}}]}`
  - `red`:
    - Peter
    - Susan
  - `blue`:
    - Rachel
    - Kate

```yaml
size: 0
query:
    filtered:
        filter:
            or:
            - term:
                gender:
                    female
            - and:
                - term:
                    color:
                        red
                - term:
                    age:
                        old

aggs:
    weighed_universe:
        sum:
            field: weighing
    options:
        terms:
            field: color
        aggs:
            weighed:
                sum:
                    field: weighing
```

## Translation

Audience expression:

```json
{
  "or": [
    {
      "gender": [
        "female "
      ]
    },
    {
      "and": [
        {
          "colour": [
            "red"
          ]
        },
        {
          "age": [
            "old"
          ]
        }
      ]
    }
  ]
}
```

Filter expression:

```json
{
  "or": [
      {
          "terms": {
              "gender": [
                  "female"
              ]
          }
      },
      {
          "and": [
              {
                  "terms": {
                      "age": [
                          "yound",
                          "middle"
                      ]
                  }
              }
          ]
      }
  ]
}
```
