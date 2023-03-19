# frozen_string_literal: true

module RactorPool
  # static sized pool with supervision
  # use multi_use at own risk - be sure to collect results before submitting more messages
  class SingleUse
    attr_reader :behavior, :inputs, :input_queue, :multi_use, :worker_count, :workers_pool

    def self.call(input, behavior, options = {})
      new(input, behavior, options)
    end

    def initialize(input, behavior, options = {})
      @worker_count = options[:worker_count] || 1
      @multi_use = (options[:multi_use] == true)

      @input_queue = create_input_queue
      @workers_pool = create_worker_pool

      @inputs = Array(input)
      @behavior = behavior

      inputs.each { |message| input_queue.send([message, behavior]) }
    end

    def results
      results = collect_results
      terminate
      results
    end

    private

    def spawn_worker
      Ractor.new(input_queue) do |queue|
        # pull work when available - terminate upon receiving nil
        until (message = queue.take).nil?
          value, comute = message
          Ractor.yield(comute.call(value))
        end
      end
    end

    def collect_results
      inputs.each_with_object([]) do |_i, answers|
        _worker, answer = Ractor.select(*workers_pool)
        answers << answer
      rescue Ractor::RemoteError => e
        dead_worker = e.ractor
        workers_pool.delete(dead_worker)
        workers_pool << spawn_worker
        puts e.inspect
      end
    end

    def create_input_queue
      Ractor.new do
        until (message = Ractor.receive) == :close
          Ractor.yield(message)
        end
      end
    end

    def terminate
      # kill all workers
      # worker_count.times { input_queue << nil }
      worker_count.times { input_queue.send(nil) }
      # kill input queue
      # input_queue << :close
      input_queue.send(:close)
      p 'terminated'
    end

    def create_worker_pool = (1..worker_count).map { |_i| spawn_worker }
  end
end

# Ractor.count # 1
# pool = RactorPool::SupervisedWorkers.call(5, Fibonacci.new)
# Ractor.count # 3 - 1 worker + 1 input queue + 1 main
# results = pool.results
# pp results
# Ractor.count # 1

# options = { worker_count: 6 }
# messages = [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19]
# Ractor.count # 1
# pool = RactorPool::SupervisedWorkers.call(messages, Fibonacci.new, options)
# Ractor.count # 8 - 6 workers + 1 input queue + 1 main
# results = pool.results
# pp results
# Ractor.count # 1

# options = { worker_count: 6, multi_use: true }
# messages = [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19]
# Ractor.count # 1
# pool = RactorPool::SupervisedWorkers.call(messages, Fibonacci.new, options)
# Ractor.count # 8 - 6 workers + 1 input queue + 1 main
# results1 = pool.results
# pp results1
# Ractor.count # 8 - 6 workers + 1 input queue + 1 main

# messages = [0, 1, 2, 3]
# pool.submit(messages, Fibonacci.new)
# Ractor.count # 8 - 6 workers + 1 input queue + 1 main
# results2 = pool.results
# restuls2
# Ractor.count # 8 - 6 workers + 1 input queue + 1 main
# pool.terminate

# Ractor.count # 1 - main

# # module FibWork
# #   def self.call(n) = [n, fib(n)]
# #   def self.fib(n) = n < 2 ? 1 : fib(n-2) + fib(n-1)
# # end

# # Ractor.count # 1
# # pool = RactorPool::ForkedPool.new(5, FibWork)
# # Ractor.count # 2
# # results = pool.results
# # Ractor.count # 1
# # results

# # messages = [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19]
# # Ractor.count # 1
# # pool = RactorPool::ForkedPool.new(messages, FibWork)
# # Ractor.count # 16
# # results = pool.results
# # Ractor.count # 1
# # results
