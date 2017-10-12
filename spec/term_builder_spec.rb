require 'spec_helper'
require './lib/term_builder'

describe 'Terms' do
  let(:audience) { nil }
  subject { TermsBuilder.new(audience).to_query }

  describe 'single term' do
    let(:audience) {  }
  end

  describe 'single term' do
    let(:audience) { {must: {gender: [:male]}} }

    it 'should return correct result' do
      expect(subject).to include({
        must: [
          terms: {
            gender: [:male]
          }
        ]
      })
    end
  end

  describe 'multiple terms' do
    let(:audience) { {must: [{colour: [:red]}, {colour: [:blue]}]} }

    it 'should return correct result' do
      expect(subject).to include({
        must: [
          {terms: {colour: [:red]}},
          {terms: {colour: [:blue]}}
        ]
      })
    end
  end
end
