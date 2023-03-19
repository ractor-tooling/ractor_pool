# frozen_string_literal: true

module RactorPool
  # using the ForkedJoin pattern - https://en.wikipedia.org/wiki/Fork%E2%80%93join_model
  # this creates a worker pool (of Ractors) as large as the number of input messages
  # and then collects the results upon completion - at which point the Ractors are
  # removed from the worker pool and available to be garbage collected
  # note: the injected behavior must respond to #call(input)
  # usage: define a behavior that responds to #call(input)
  # class Fibonacci
  #   def call(n) = [n, fib(n)]
  #   def fib(n) = n < 2 ? 1 : fib(n-2) + fib(n-1)
  # end
  # and pass it to the pool
  # pool = Ractors::ForkedPool.new(5, Fibonacci.new)
  # do other stuff
  # results = pool.results # this will block until all workers are done
  # Ractor.count # 1 (main ractor / thread)
  # more examples in examples and in spec/ractor_pool/forked_join_spec.rb
  class ForkedJoin
    attr_reader :behavior, :messages, :workers

    def self.call(inputs, behavior) = new(inputs, behavior)

    def initialize(inputs, behavior)
      @behavior = behavior
      @messages = Array(inputs)
      @workers = messages.map { |message| spawn_ractor(message) }
    end

    # removes ractors when done and GC removes
    def results
      results = []
      until workers.empty?
        begin
          worker, result = Ractor.select(*workers)
          workers.delete(worker)
          results << result
        rescue Ractor::RemoteError => e
          # log error e.inspect
          puts e.inspect
        end
      end
      results
    end

    private

    def spawn_ractor(message)
      ractor = Ractor.new do
        number, calculation = Ractor.receive
        Ractor.yield calculation.call(number)
      end
      ractor.send([message, behavior])
    end
  end
end

# class Fibonacci
#   def call(n) = [n, fib(n)]
#   def fib(n) = n < 2 ? 1 : fib(n-2) + fib(n-1)
# end

# Ractor.count # 1
# pool = RactorPool::ForkedPool.new(5, Fibonacci.new)
# Ractor.count # 2
# results = pool.results
# Ractor.count # 1

# messages = [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19]
# Ractor.count # 1
# pool = RactorPool::ForkedPool.new(messages, Fibonacci.new)
# Ractor.count # 16
# results = pool.results
# Ractor.count # 1


# module FibWork
#   def self.call(n) = [n, fib(n)]
#   def self.fib(n) = n < 2 ? 1 : fib(n-2) + fib(n-1)
# end

# Ractor.count # 1
# pool = RactorPool::ForkedPool.new(5, FibWork)
# Ractor.count # 2
# results = pool.results
# Ractor.count # 1
# results

# messages = [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19]
# Ractor.count # 1
# pool = RactorPool::ForkedPool.new(messages, FibWork)
# Ractor.count # 16
# results = pool.results
# Ractor.count # 1
# results
