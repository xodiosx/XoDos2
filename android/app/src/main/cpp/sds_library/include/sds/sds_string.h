// Copyright (c) 2021-present Art of the State LLC
// Under MIT License. See LICENSE.md for details

#pragma once

#include <map>
#include <string>
#include <vector>

namespace sds
{
	/// Returns an array of strings by splitting inputString by separator
	std::vector<std::string> stringSplit( const std::string &inputString, const char separator );

	/** Returns a key-value map by separator
	@remarks
		Its main purpose is to parse something exactly like the following:

		@code
			std::string inputString = "a=0 b=3 c=5"
			auto stringVector = sds::stringSplit( inputString, ' ' );
			auto myMap = sds::stringSplit( stringVector, '=' );

			printf( "%s", myMap["b"].c_str() ); // prints 3
		@endcode
	@param inputStrings
		A vector of strings
	@param separator
		Separator to find in each string from inputStrings.
		Only the first ocurrence is considered. Everything that comes before becomes the key,
		everything afterwards is the value

		If separator is not found, nothing is added to the map
		Empty keys are skipped
		Empty values are considered
	*/
	std::map<std::string, std::string> stringMap( const std::vector<std::string> &inputStrings,
												  const char                      separator );

	/** Converts 'value' to an integer into outValue
	@param value
		String containing an integer
	@param outValue
		Integer. May be left untouched if returns false
	@return
		False on error
	*/
	bool toU32( const std::string &value, uint32_t &outValue );

	/** Returns an integer of 'value'
	@param value
		String containing an integer
	@param defaultVal
		Default value to set in case we fail to convert
	@return
		Converted integer (or defaultVal)
	*/
	uint32_t toU32withDefault( const std::string &value, uint32_t defaultVal = 0u );

	/** Converts 'value' to an integer into outValue
	@param value
		String containing an integer
	@param outValue
		Integer. May be left untouched if returns false
	@return
		False on error
	*/
	bool toU16( const std::string &value, uint16_t &outValue );

	/** Returns an integer of 'value'
	@param value
		String containing an integer
	@param defaultVal
		Default value to set in case we fail to convert
	@return
		Converted integer (or defaultVal)
	*/
	uint16_t toU16withDefault( const std::string &value, uint16_t defaultVal = 0u );
}  // namespace sds
