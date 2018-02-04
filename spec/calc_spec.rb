require 'spec_helper'
require './lib/calculator'

describe 'Calculations' do
  let(:red_likers_audience) { {and: [{colour: [:red]}]} }
  let(:female_or_not_old_audience) { {or: [{gender: [:female]}, {age: [:young, :middle]}]} }
  let(:red_and_blue_audience) { {and: [{colour: [:red]}, {colour: [:blue]}]} }

  let(:respondents) do
    [
      { id: 'john', weighting: 1100, answers: { gender: [:male], age: [:young], colour: [:red] } },
      { id: 'petr', weighting: 1100, answers: { gender: [:male], age: [:old], colour: [:red] } },
      { id: 'steve', weighting: 1100, answers: { gender: [:male], age: [:middle], colour: [:blue] } },
      { id: 'rachel', weighting: 1000, answers: { gender: [:female], age: [:young], colour: [:blue] } },
      { id: 'susan', weighting: 1000, answers: { gender: [:female], age: [:old], colour: [:red] } },
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
      expect(subject.detect{|o| o[:option] == 'male'}[:responses_count]).to eq(3)
    end

    it 'should return correct result' do # male: john, peter, steve | female: rachel, susan, cate
      expect(subject).to match_array([
        { option: 'male', responses_count: 3, weighted: 3300, percentage: 52.38 },
        { option: 'female', responses_count: 3, weighted: 3000, percentage: 47.62 }
      ])
    end

    context "with red likers audience" do # red: john, peter, susan | male: john, peter | female: susan
      let(:audience) { red_likers_audience }
      it 'should return correct result' do
        expect(subject).to match_array([
          { option: 'male', responses_count: 2, weighted: 2200, percentage: 68.75 },
          { option: 'female', responses_count: 1, weighted: 1000, percentage: 31.25 }
        ])
      end
    end

    context "with red and blue likers audience" do # todo
      let(:audience) { red_and_blue_audience }
      it 'should return correct result' do
        expect(subject).to match_array([
          { option: 'male', responses_count: 3, weighted: 3300, percentage: 52.38 }, # 3300 / (3300 + 3000) = 0.5238095238095238
          { option: 'female', responses_count: 3, weighted: 3000, percentage: 47.62 } # 3000 / (3300 + 3000) = 0.47619047619047616
        ])
      end
    end

  end # gender question

  context "colour question" do
    let(:question) { :colour }

    # TODO: make test

    context "with female or not old audience" do
      let(:audience) { female_or_not_old_audience }

      # TODO: make test
    end

    context "with female || (red && old) audience" do
      let(:female_or_red_old_audience) { } # TODO: create an audience
      let(:audience) { female_or_red_old_audience }

      # TODO: make test
    end
  end
end
