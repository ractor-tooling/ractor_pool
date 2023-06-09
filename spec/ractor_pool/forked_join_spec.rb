# frozen_string_literal: true

require 'spec_helper'
require 'ractor_pool_spec'
require 'ractor_pool/forked_join'

# class Fibonacci
#   def call(n) = [n, fib(n)]
#   def fib(n) = n < 2 ? 1 : fib(n-2) + fib(n-1)
# end

# module FibWork
#   def self.call(n) = [n, fib(n)]
#   def self.fib(n) = n < 2 ? 1 : fib(n-2) + fib(n-1)
# end

RSpec.describe RactorPool::ForkedJoin do
  subject(:pool) { described_class.call(inputs, behavior) }

  before { expect(Ractor.count).to eq(1) }
  after { expect(Ractor.count).to eq(1) }

  context 'without a pool' do
    it { expect(Ractor.count).to eq(1) }
  end

  let(:expected_ractor_count) { Array(inputs).count + 1 } # 1 for the main ractor

  context 'when behavior is a class' do
    let(:behavior) { Fibonacci.new }

    # let(:behavior) { Fibonacci.new }
    # let(:behavior) do
    #   Class.new do
    #     def call(n) = [n, fib(n)]
    #     def fib(n) = n < 2 ? 1 : fib(n-2) + fib(n-1)
    #   end
    # end

    # before do
    #   stub_const('Fibonacci', behavior)
    # end

    context 'with a single input' do
      let(:inputs) { 5 }
      let(:expected_results) { [[5, 8]] }

      context 'when the pool is created' do
        after { pool.results; sleep(0.1) }

        it { expect(pool).to be_a(described_class) }

        it 'it creates an additional ractor for each input' do
          pool
          expect(Ractor.count).to eq(expected_ractor_count)
        end
      end

      it 'returns the expected result' do
        expect(pool.results).to eq(expected_results)
      end
    end

    context 'with multiple inputs' do
      let(:inputs) { [5, 6, 7] }
      let(:expected_results) { [[5, 8], [6, 13], [7, 21]] }

      context 'when the pool is created' do
        after { pool.results; sleep(0.1) }

        it 'it creates an additional ractor for each input' do
          pool
          expect(Ractor.count).to eq(expected_ractor_count)
        end
      end

      context 'after the results are returned' do
        before do
          pool.results
          sleep(0.1) # Garbage collection needs time to run
        end

        it 'the Ractor count is reduced' do
          expect(Ractor.count).to eq(1) # 1 for the main ractor
        end
      end

      it 'returns the expected result' do
        expect(pool.results).to match_array(expected_results)
      end
    end

    context 'with malformed inputs' do
      let(:inputs) { [5, '6', 7] }
      let(:expected_results) { [[5, 8], [7, 21]] }

      context 'when the pool is created' do
        after { pool.results; sleep(0.1) }

        it 'it creates an additional ractor for each input' do
          pool
          expect(Ractor.count).to eq(expected_ractor_count)
        end
      end

      context 'after the results are returned' do
        before do
          pool.results
          sleep(0.1) # Garbage collection needs time to run
        end

        it 'the Ractor count is reduced' do
          expect(Ractor.count).to eq(1) # 1 for the main ractor
        end
      end

      it 'returns the expected result' do
        expect(pool.results).to match_array(expected_results)
      end
    end
  end

  context 'when behavior is a module' do
    let(:behavior) { FibWork }

    context 'with a single input' do
      let(:inputs) { 5 }
      let(:expected_results) { [[5, 8]] }

      context 'when the pool is created' do
        after { pool.results; sleep(0.1) }

        it { expect(pool).to be_a(described_class) }

        it 'it creates an additional ractor for each input' do
          pool
          expect(Ractor.count).to eq(expected_ractor_count)
        end
      end

      context 'after the results are returned' do
        before { pool.results }

        it 'the Ractor count is reduced' do
          expect(Ractor.count).to eq(1) # 1 for the main ractor
        end
      end

      it 'returns the expected result' do
        expect(pool.results).to eq(expected_results)
        sleep(0.1) # Garbage collection needs time to run
      end
    end

    context 'with multiple inputs' do
      let(:inputs) { [5, 6, 7] }
      let(:expected_results) { [[5, 8], [6, 13], [7, 21]] }

      context 'when the pool is created' do
        after { pool.results; sleep(0.1) }

        it 'it creates an additional ractor for each input' do
          pool
          expect(Ractor.count).to eq(expected_ractor_count)
        end
      end

      it 'returns the expected result' do
        expect(pool.results).to match_array(expected_results)
        sleep(0.1) # Garbage collection needs time to run
      end
    end
  end

  xcontext 'when behavior is a Proc' do
    let(:inputs) { 5 }
    let(:behavior) { ->(n) { [n, n * 2] } }
    let(:expected_results) { [[5, 8]] }

    it 'returns the expected result' do
      expect(pool.results).to match_array(expected_results)
      sleep(0.1) # Garbage collection needs time to run
    end
  end
end

# # Ractor.count # 1
# # pool = Ractors::ForkedPool.new(5, Fibonacci.new)
# # Ractor.count # 2
# # results = pool.results
# # Ractor.count # 1

# # messages = [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19]
# # Ractor.count # 1
# # pool = Ractors::ForkedPool.new(messages, Fibonacci.new)
# # Ractor.count # 16
# # results = pool.results
# # Ractor.count # 1

# # module FibWork
# #   def self.call(n) = [n, fib(n)]
# #   def self.fib(n) = n < 2 ? 1 : fib(n-2) + fib(n-1)
# # end

# # Ractor.count # 1
# # pool = Ractors::ForkedPool.new(5, FibWork)
# # Ractor.count # 2
# # results = pool.results
# # Ractor.count # 1
# # results

# # messages = [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19]
# # Ractor.count # 1
# # pool = Ractors::ForkedPool.new(messages, FibWork)
# # Ractor.count # 16
# # results = pool.results
# # Ractor.count # 1
# # results
