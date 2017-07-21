require 'spec_helper'
require './lib/calculator'

describe 'Calculations' do

  # Questions
  # gender: [male, female]
  # age: [young, middle, old]
  # colour: [red, blue]

  # Audiences
  let(:old_male_audience) { {and: [{gender: [:male]}, {age: [:old]}]} }
  let(:red_likers_audience) { {and: [{colour: [:red]}]} }

  let(:respondents) do
    [ # id, wave, location, weighting, responses
      { id: 'john', weighting: 1100, answers: { gender: [:male], age: [:young], colour: [:red] } },
      { id: 'petr', weighting: 1100, answers: { gender: [:male], age: [:old], colour: [:red] } },
      { id: 'steve', weighting: 1100, answers: { gender: [:male], age: [:old], colour: [:blue] } },
      { id: 'rachel', weighting: 1000, answers: { gender: [:female], age: [:young], colour: [:blue] } },
      { id: 'susan', weighting: 1000, answers: { gender: [:female], age: [:middle], colour: [:red] } },
      { id: 'cate', weighting: 1000, answers: { gender: [:female], age: [:middle], colour: [:blue] } }
    ]
  end

  before do
    EsHelpers.create_index
    EsHelpers.seed_respondents(respondents)
  end

  after do
    EsHelpers.destroy_index
  end

  subject { Calculator.new(question: question, audience: audience).result }
  let(:question) { nil }
  let(:audience) { nil }

  context "gender question" do
    let(:question) { :gender }

    it 'has correct responses count for male' do
      # This is warming green test
      expect(subject.detect{|o| o[:option] == 'male'}[:responses_count]).to eq(3)
    end

    it 'should return correct result' do
      # male: john, peter, steve
      # female: rachel, susan, cate
      expect(subject).to match_array([
        {
          option: 'male',
          responses_count: 3,
          weighted: 3300,
          percentage: 52.4
        },
        {
          option: 'female',
          responses_count: 3,
          weighted: 3000,
          percentage: 47.6
        }
      ])
    end

    context "with red likers audience" do
      # red: john, peter, susan
      #   male: john, peter
      #   female: susan
      it 'should return correct result' do
        expect(subject).to match_array([
          {
            option: 'male',
            responses_count: 2,
            weighted: 2200,
            percentage: 68.8
          },
          {
            option: 'female',
            responses_count: 1,
            weighted: 1000,
            percentage: 31.3
          }
        ])
      end
    end
  end # gender question

  context "colour question" do
    # TODO: make test
    context "with old male audience" do
      # TODO: make test
    end
  end
end
