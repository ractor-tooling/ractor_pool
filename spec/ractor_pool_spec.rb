# frozen_string_literal: true

class Fibonacci
  def call(n) = [n, fib(n)]
  def fib(n) = n < 2 ? 1 : fib(n-2) + fib(n-1)
end

module FibWork
  def self.call(n) = [n, fib(n)]
  def self.fib(n) = n < 2 ? 1 : fib(n-2) + fib(n-1)
end

RSpec.describe RactorPool do
  it 'has a version number' do
    expect(RactorPool::VERSION).not_to be nil
  end

end
