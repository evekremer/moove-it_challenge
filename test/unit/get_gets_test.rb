require_relative "../test_helper"

class GetGetsTest < BaseTest

  ###########     Get     ###########

  def test_simple_multi_get
    # Set and get 5 items
    exp_reply_multi = ""
    keys = Array.new

    5.times{ |i|
      key_ = "key#{i}"
      value_ = "value#{i}"
      send_storage_cmd("set", key_, 2, 8000, value_.length(), false, value_, true)
      
      reply = send_get_cmd(key_)
      exp_reply = expected_get_response(key_, 2, value_.length(), value_, false)
      assert_equal exp_reply, reply

      exp_reply_multi += expected_get_response(key_, 2, value_.length(), value_, false, true)
      keys[i] = key_
    }

    # Get multiple for stored keys
    exp_reply_multi.concat(END_MSG)
    reply_multi = send_multi_get_cmd(keys)
    assert_equal exp_reply_multi, reply_multi
  end
  
  def test_get_empty_key
    socket.puts "get       \r\n"
    assert_equal "CLIENT_ERROR <key>* must be provided\r\n", socket.gets

    socket.puts "get\r\n"
    assert_equal "CLIENT_ERROR <key>* must be provided\r\n", socket.gets
  end

  def test_all_missing_multi_get
    socket.puts "get #{key}1 #{key}2 #{key}3 #{key}4\r\n"
    assert_equal END_MSG, socket.gets
  end

  def test_all_empty_value_multi_get
    # Set and gets 5 items
    exp_reply_multi = ""
    keys = Array.new

    5.times{ |i|
      key_ = "#{key}#{i}"
      send_storage_cmd("set", key_, 1, 1000, 0, false, nil, true)
      exp_reply_multi += expected_get_response(key_, 1, 0, nil, false, true)
      keys[i] = key_
    }

    # Gets multiple empty values for stored keys
    exp_reply_multi.concat(END_MSG)
    reply_multi = send_multi_get_cmd(keys)
    assert_equal exp_reply_multi, reply_multi
  end

  def test_some_missing_keys_multi_get
    exp_reply_multi = ""

    send_storage_cmd("set", "#{key}1", 3, 300, value.length(), false, value, true)
    exp_reply_multi += expected_get_response("#{key}1", 3, value.length(), value, false, true)

    send_storage_cmd("set", "#{key}3", 4, 500, value.length(), false, value, true)
    exp_reply_multi += expected_get_response("#{key}3", 4, value.length(), value)

    socket.puts "get #{key}1 #{key}2 #{key}3 #{key}4 #{key}5\r\n"
    reply = ""
    5.times { reply += socket.gets }
    assert_equal exp_reply_multi, reply
  end

###########     Gets     ###########

  def test_simple_multi_gets
    # Set and gets 5 items
    exp_reply_multi = ""
    keys = Array.new

    5.times{ |i|
      key_ = "#{i}key"
      value_ = "#{i}value"

      send_storage_cmd("set", key_, 5, 500, value_.length(), false, value_, true)
      reply = send_get_cmd(key_, true) # send gets for key_ and read reply
      
      ck =  get_cas_key(key_)
      exp_reply = expected_get_response(key_, 5, value_.length(), value_, ck, false)

      assert_equal exp_reply, reply

      exp_reply_multi += expected_get_response(key_, 5, value_.length(), value_, ck, true)
      keys[i] = key_
    }

    # Gets multiple for stored keys
    exp_reply_multi.concat(END_MSG)
    reply_multi = send_multi_get_cmd(keys, true)

    assert_equal exp_reply_multi, reply_multi
  end

  def test_gets_empty_key
    socket.puts "gets       \r\n"
    assert_equal "CLIENT_ERROR <key>* must be provided\r\n", socket.gets

    socket.puts "gets\r\n"
    assert_equal "CLIENT_ERROR <key>* must be provided\r\n", socket.gets
  end

  def test_all_missing_multi_gets
    socket.puts "gets #{key}1 #{key}2 #{key}3 #{key}4\r\n"
    assert_equal END_MSG, socket.gets
  end

  def test_all_empty_value_multi_gets
    # Set and gets 5 items
    exp_reply_multi = ""
    keys = Array.new

    5.times{ |i|
      key_ = "#{key}#{i}"
      send_storage_cmd("set", key_, 1, 1000, 0, false, nil, true)
      exp_reply_multi += expected_get_response(key_, 1, 0, nil, get_cas_key(key_), true)
      keys[i] = key_
    }

    # Gets multiple empty values for stored keys
    exp_reply_multi.concat(END_MSG)
    reply_multi = send_multi_get_cmd(keys, true)
    assert_equal exp_reply_multi, reply_multi
  end

  def test_some_missing_keys_multi_gets
    exp_reply_multi = ""

    send_storage_cmd("set", "#{key}1", 3, 300, value.length(), false, value, true)
    exp_reply_multi += expected_get_response("#{key}1", 3, value.length(), value, get_cas_key("#{key}1"), true)

    send_storage_cmd("set", "#{key}3", 4, 500, value.length(), false, value, true)
    exp_reply_multi += expected_get_response("#{key}3", 4, value.length(), value, get_cas_key("#{key}3"))

    socket.puts "gets #{key}1 #{key}2 #{key}3 #{key}4 #{key}5\r\n"
    reply = ""
    5.times { reply += socket.gets }
    assert_equal exp_reply_multi, reply
  end
end
