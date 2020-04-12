# "add": means "store this data, but only if the server *doesn't* already hold data for this key".
# "replace" means "store this data, but only if the server *does* already hold data for this key".

require_relative "../test_helper"

class AddReplaceTest < BaseTest

  ###########     Add     ###########

  def test_simple_add
    send_storage_cmd("add", key, 5, 6000, value.length(), false, value, false)
    assert_equal Memcached::STORED_MSG, socket.gets
    
    # Get the item and assert reply
    reply = send_get_cmd(key)
    assert_equal expected_get_response(key, 5, value.length(), value), reply
  end

  def test_existing_key_add
    send_storage_cmd("set", key, 2, 100, value.length(), false, value, false)
    assert_equal Memcached::STORED_MSG, socket.gets

    value2 = "new_value"
    send_storage_cmd("add", key, 5, 2000, value2.length(), false, value2, false)
    assert_equal Memcached::NOT_STORED_MSG, socket.gets

    # Get stored item with "set" and assert reply
    reply = send_get_cmd(key)
    assert_equal expected_get_response(key, 2, value.length(), value), reply
  end

  # def test_exptime_add
  #   # Add item that expires in 3 seconds
  #   send_storage_cmd("add", key, 8, 3, value.length(), false, value, false)
  #   assert_equal Memcached::STORED_MSG, socket.gets

  #   # Get stored item
  #   reply = send_get_cmd(key)
  #   assert_equal expected_get_response(key, 8, value.length(), value), reply

  #   sleep(4)

  #   # Get expired item
  #   reply = send_get_cmd(key)
  #   assert_equal Memcached::END_MSG, reply
  # end

  def test_no_reply_add
    send_storage_cmd("add", key, 2, 9800, value.length(), false, value, true)
    sleep(2)
    # Get stored item
    reply = send_get_cmd(key)
    assert_equal expected_get_response(key, 2, value.length(), value), reply
  end
  
  
  ###########     Replace     ###########

  def test_simple_replace
    send_storage_cmd("set", key, 2, 100, value.length(), false, value, false)
    assert_equal Memcached::STORED_MSG, socket.gets

    value2 = "new_value"
    send_storage_cmd("replace", key, 5, 6000, value2.length(), false, value2, false)
    assert_equal Memcached::STORED_MSG, socket.gets

    # Get stored item with updated value
    reply = send_get_cmd(key)
    assert_equal expected_get_response(key, 5, value2.length(), value2), reply
  end

  def test_missing_key_replace
    send_storage_cmd("replace", key, 5, 6000, value.length(), false, value, false)
    assert_equal Memcached::NOT_STORED_MSG, socket.gets

    reply = send_get_cmd(key)
    assert_equal Memcached::END_MSG, reply
  end

  # def test_exptime_replace
  #   # Set item that never expires (exptime = 0)
  #   send_storage_cmd("set", key, 2, 0, value.length(), false, value, false)
  #   assert_equal Memcached::STORED_MSG, socket.gets

  #   # Replace for item that expires in 3 seconds
  #   val2 = "new_value"
  #   send_storage_cmd("replace", key, 8, 3, val2.length(), false, val2, false)
  #   assert_equal Memcached::STORED_MSG, socket.gets

  #   # Get stored item
  #   reply = send_get_cmd(key)
  #   assert_equal expected_get_response(key, 8, val2.length(), val2), reply

  #   # Get expired item
  #   sleep(4)
  #   reply = send_get_cmd(key)
  #   assert_equal Memcached::END_MSG, reply
  # end

  def test_no_reply_replace
    send_storage_cmd("set", key, 2, 100, value.length(), false, value, false)
    assert_equal Memcached::STORED_MSG, socket.gets

    val2 = "new_value"
    send_storage_cmd("replace", key, 2, 9800, val2.length(), false, val2, true)
    sleep(2)
    # Get stored item
    reply = send_get_cmd(key)
    assert_equal expected_get_response(key, 2, val2.length(), val2), reply
  end
end