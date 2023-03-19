
class Fibonacci
  def call(n) = [n, fib(n)]
  def fib(n) = n < 2 ? 1 : fib(n-2) + fib(n-1)
end

Ractor.count # 1
pool = Ractors::ForkedPool.new(5, Fibonacci.new)
Ractor.count # 2
results = pool.results
Ractor.count # 1

messages = [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19]
Ractor.count # 1
pool = Ractors::ForkedPool.new(messages, Fibonacci.new)
Ractor.count # 16
results = pool.results
Ractor.count # 1

class Fibonacci
  def call(n) = [n, fib(n)]
  def fib(n) = n < 2 ? 1 : fib(n-2) + fib(n-1)
end

module FibWork
  def self.call(n) = [n, fib(n)]
  def self.fib(n) = n < 2 ? 1 : fib(n-2) + fib(n-1)
end

Ractor.count # 1
pool = Ractors::ForkedPool.new(5, FibWork)
Ractor.count # 2
results = pool.results
Ractor.count # 1
results

messages = [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19]
Ractor.count # 1
pool = Ractors::ForkedPool.new(messages, FibWork)
Ractor.count # 16
results = pool.results
Ractor.count # 1
results
