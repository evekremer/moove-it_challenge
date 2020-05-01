module Memcached
  # Response messages
  CMD_ENDING = "\r\n"
  STORED_MSG = 'STORED' + CMD_ENDING
  NOT_STORED_MSG = 'NOT_STORED' + CMD_ENDING
  NOT_FOUND_MSG = 'NOT_FOUND' + CMD_ENDING
  EXISTS_MSG = 'EXISTS' + CMD_ENDING
  INVALID_COMMAND_NAME_MSG = 'ERROR' + CMD_ENDING
  END_MSG = 'END' + CMD_ENDING

  # Expiration date
  SECONDS_PER_DAY = 60*60*24
  UNIX_TIME = Time.new(1970,1,1)
  
  ONE_MEGABYTE = (2 ** 20)
  MAX_KEY_LENGTH = 250
  MAX_DATA_BLOCK_LENGTH = ONE_MEGABYTE # 1MB
  MAX_CAS_KEY = (2 ** 64) - 1 # 64-bit unsigned int
  MAX_CACHE_CAPACITY = 64 * ONE_MEGABYTE # 64MB

  PURGE_EXPIRED_KEYS_FREQUENCY_SECS = 10

  # Command names
  SET_CMD_NAME = 'set'
  ADD_CMD_NAME = 'add'
  REPLACE_CMD_NAME = 'replace'
  PREPEND_CMD_NAME = 'prepend'
  APPEND_CMD_NAME = 'append'
  CAS_CMD_NAME = 'cas'
  GET_CMD_NAME = 'get'
  GETS_CMD_NAME = 'gets'
  NO_REPLY = 'noreply'

  # Response error messages
  
  CLIENT_ERROR = 'CLIENT_ERROR '
  VALUE_LABEL = 'VALUE '
  TOO_MANY_ARGUMENTS_MSG = CLIENT_ERROR + 'The command has too many arguments' + CMD_ENDING
  TOO_FEW_ARGUMENTS_MSG = CLIENT_ERROR + 'The command has too few arguments' + CMD_ENDING

  EXPTIME_TYPE_MSG = CLIENT_ERROR + '<exptime> is not an integer' + CMD_ENDING
  FLAGS_TYPE_MSG = CLIENT_ERROR + '<flags> is not a 16-bit unsigned integer' + CMD_ENDING
  LENGTH_TYPE_MSG = CLIENT_ERROR + '<length> is not an unsigned integer' + CMD_ENDING
  CAS_KEY_TYPE_MSG = CLIENT_ERROR + '<cas_unique> is not a 64-bit unsigned integer' + CMD_ENDING

  CMD_TERMINATION_MSG = CLIENT_ERROR + 'Commands must be terminated by "\r\n"' + CMD_ENDING

  KEY_NOT_PROVIDED_MSG = CLIENT_ERROR + '<key> must be provided' + CMD_ENDING
  KEYS_NOT_PROVIDED_MSG = CLIENT_ERROR + '<key>* must be provided' + CMD_ENDING
  KEY_WITH_CONTROL_CHARS_MSG = CLIENT_ERROR + '<key> must not include control characters' + CMD_ENDING

  KEY_TOO_LONG_MSG = CLIENT_ERROR + "<key> has more than #{MAX_KEY_LENGTH} characters" + CMD_ENDING
  DATA_BLOCK_TOO_LONG_MSG = CLIENT_ERROR + "<data_block> has more than #{MAX_DATA_BLOCK_LENGTH} characters" + CMD_ENDING

  class ArgumentClientError < StandardError; end
  class TypeClientError < StandardError; end

  module Util
    def validate_key!(key)
      raise TypeClientError, KEY_NOT_PROVIDED unless key != ""
      raise TypeClientError, KEY_WITH_CONTROL_CHARS_MSG if has_control_characters? key
      raise TypeClientError, KEY_TOO_LONG_MSG unless key.length() <= MAX_KEY_LENGTH
    end

    def validate_exptime!(exptime)
      raise TypeClientError, EXPTIME_TYPE_MSG unless is_i? exptime
    end

    def validate_length!(length)
      raise TypeClientError, LENGTH_TYPE_MSG unless is_unsigned_i? length
    end

    def validate_flags!(flags)
      raise TypeClientError, FLAGS_TYPE_MSG unless is_unsigned_i?(flags, 16)
    end

    def validate_parameters_min_length!(parameters, min_length)
      raise ArgumentClientError, TOO_FEW_ARGUMENTS_MSG unless parameters.length() >= min_length
    end

    def validate_data_block!(length, data_block)
      # Validate that data_block does not exceed maximum length
      raise TypeClientError, DATA_BLOCK_TOO_LONG_MSG unless data_block.length() <= MAX_DATA_BLOCK_LENGTH
      
      # Validate that 'length' parameter corresponds to the actual data_block length
      raise ArgumentClientError, CLIENT_ERROR + "<length> (#{length}) is not equal to the length of the item's data_block (#{data_block.length()})" + CMD_ENDING unless data_block.length() == length.to_i
    end

    def is_unsigned_i?(data, num_bits = nil)
      is_int = /\A\d+\z/ === data
      within_valid_range = (num_bits ? data.to_i < 2**num_bits && data.to_i >= 0 : true )
      is_int && within_valid_range
    end

    def is_i?(data)
      /\A[-+]?\d+\z/ === data
    end

    def has_control_characters?(data)
      /\x00|[\cA-\cZ]/ =~ data
    end

    def is_expired?(data)
      data.to_i != 0 && Time.now >= data
    end
  end
end