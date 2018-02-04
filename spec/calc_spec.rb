require 'spec_helper'
require './lib/calculator'

describe 'Calculations' do
  let(:red_likers_audience) { {and: [{colour: [:red]}]} }
  let(:female_or_not_old_audience) { {or: [{gender: [:female]}, {age: [:young, :middle]}]} }
  let(:red_and_blue_audience) { {and: [{colour: [:red]}, {colour: [:blue]}]} }
  let(:female_or_red_old_audience) { {or: [{ gender: [:female] }, {and: [{ colour: [:red] }, { age: [:old] }]}]}}

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
      # sanity
      expect(subject.detect{|o| o[:option] == 'male'}[:responses_count]).to eq(3)
    end

    it 'should return correct result' do
      # male: john 1100, peter 1100, steve 1100 = 3300 => 3300 / 6300 = 52.38 %
      # female: rachel 1000, susan 1000, kate 1000 = 3000 => 3000 / 6300 = 47.62 %
      expect(subject).to match_array([
        { option: 'male', responses_count: 3, weighted: 3300, percentage: 52.38 },
        { option: 'female', responses_count: 3, weighted: 3000, percentage: 47.62 }
      ])
    end

    context "with red likers audience" do
      let(:audience) { red_likers_audience }
      it 'should return correct result' do
        # male: john 1100, peter 1100 = 2200 => 2200 / 3200 = 68.75 %
        # female: susan 1000 = 1000 = 1000 => 1000 / 3200 = 31.25 %
        expect(subject).to match_array([
          { option: 'male', responses_count: 2, weighted: 2200, percentage: 68.75 },
          { option: 'female', responses_count: 1, weighted: 1000, percentage: 31.25 }
        ])
      end
    end

    context "with red and blue likers audience" do
      let(:audience) { red_and_blue_audience }
      it 'should return correct result' do
        # This should be empty, because we do not support liking multiple colors at the same time!
        expect(subject).to match_array([ ])
      end
    end

  end # gender question

  context "colour question" do
    let(:question) { :colour }

    it 'has correct responses count for red' do
      # sanity
      expect(subject.detect{|o| o[:option] == 'red'}[:responses_count]).to eq(3)
    end

    context "with female or not old audience" do
      let(:audience) { female_or_not_old_audience }
      it 'should return correct result' do
        # blue: steve 11000, rachel 1000, kate 1000 = 3100 => 3100 / 5200 = 59.62 %
        # red: john 1100, susan 1000 = 2100 => 2100 / 5200 = 40.38 %
        expect(subject).to match_array([
          { option: 'blue', responses_count: 3, weighted: 3100, percentage: 59.62 },
          { option: 'red', responses_count: 2, weighted: 2100, percentage: 40.38 }
        ])
      end
    end

    context "with female || (red && old) audience" do
      let(:audience) { female_or_red_old_audience }
      it 'should return correct result' do
        # red: peter 1100, susan 1000 = 2100 => 2100 / 4100 = 51.22
        # blue: rachel 1000, kate 1000 => 2000 => 2000 / 4100 = 48.78
        expect(subject).to match_array([
          { option: 'blue', responses_count: 2, weighted: 2000, percentage: 48.78 },
          { option: 'red', responses_count: 2, weighted: 2100, percentage: 51.22 }
        ])
      end
    end
  end
end
