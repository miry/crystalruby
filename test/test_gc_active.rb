# frozen_string_literal: true

require_relative "test_helper"

class TestGCActive < Minitest::Test
  module ::MemoryGobbler
    crystal lib: "memory_gobbler" do
      @@leaked_memory = ""
    end

    crystalize lib: "memory_gobbler"
    def gobble_gcable_memory(mb: :float)
      "a" * (mb * 1024 * 1024).to_i
    end

    crystalize lib: "memory_gobbler"
    def leak_memory(mb: :float)
      @@leaked_memory += "a" * (mb * 1024 * 1024).to_i
    end

    crystalize :uint64, async: true, lib: "memory_gobbler"
    def trigger_gc
      5.times do
        sleep 0.001.seconds
        GC.collect
      end
      GC.stats.heap_size
    end
  end

  def test_gc_kicks_in
    baseline_heap = MemoryGobbler.trigger_gc
    100.times do
      MemoryGobbler.leak_memory(0.5)
    end
    leaked_heap = MemoryGobbler.trigger_gc
    assert (leaked_heap - baseline_heap) / (1024**2) > 50

    baseline_heap = leaked_heap
    100.times do
      MemoryGobbler.gobble_gcable_memory(0.5)
    end
    released_heap = MemoryGobbler.trigger_gc
    assert (released_heap - baseline_heap) / (1024**2) < 10
  end

  class ObjectAllocTest < CRType do
    NamedTuple(hash: Hash(Int32, Int32), string: String, array: Array(Int32))
  end
  end

  crystalize
  def crystal_gc
    GC.collect
  end

  crystalize
  def crystal_alloc(returns: ObjectAllocTest)
    ObjectAllocTest.new({ hash: { 1 => 2 }, string: "hello", array: [1, 2, 3] })
  end

  crystalize
  def store_for_later(value: ObjectAllocTest)
    @@value = value
  end

  crystalize
  def clear_stored_value
    @@value = nil
    GC.collect
  end

  def test_crystal_alloc_crystal_free
    object = crystal_alloc
    ptr = FFI::Pointer.new(object.address)
    assert_equal ptr.read_int32, 2
    object = nil
    GC.start
    assert_equal ptr.read_int32, 1
    crystal_gc
    refute_equal ptr.read_int32, 1
    refute_equal ptr.read_int32, 0
  end

  def test_ruby_alloc_crystal_free
    object = ObjectAllocTest.new({ hash: { 1 => 2 }, string: "hello", array: [1, 2, 3] })
    store_for_later(object)
    ptr = FFI::Pointer.new(object.address)
    assert_equal ptr.read_int32, 2
    object = nil
    GC.start
    assert_equal ptr.read_int32, 1
    clear_stored_value
    refute_equal ptr.read_int32, 1
    refute_equal ptr.read_int32, 0
  end

  def test_crystal_alloc_ruby_free
    object = crystal_alloc
    ptr = FFI::Pointer.new(object.address)
    assert_equal ptr.read_int32, 2
    crystal_gc
    assert_equal ptr.read_int32, 1
    object = nil
    GC.start
    refute_equal ptr.read_int32, 1
    refute_equal ptr.read_int32, 0
  end
end