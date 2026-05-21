// Copyright (c) 2021-present Art of the State LLC
// Under MIT License. See LICENSE.md for details

#include "sds/sds_string.h"

namespace sds
{
	std::vector<std::string> stringSplit( const std::string &inputString, const char separator )
	{
		std::vector<std::string> output;

		std::string::size_type prev_pos = 0, pos = 0;

		while( ( pos = inputString.find( separator, pos ) ) != std::string::npos )
		{
			std::string substring( inputString.substr( prev_pos, pos - prev_pos ) );
			output.push_back( substring );
			prev_pos = ++pos;
		}

		output.push_back( inputString.substr( prev_pos, pos - prev_pos ) );  // Last word

		return output;
	}
	//-------------------------------------------------------------------------
	std::map<std::string, std::string> stringMap( const std::vector<std::string> &inputStrings,
												  const char separator )
	{
		std::map<std::string, std::string> retVal;

		std::vector<std::string>::const_iterator itor = inputStrings.begin();
		std::vector<std::string>::const_iterator endt = inputStrings.end();

		while( itor != endt )
		{
			const size_t pos = itor->find( separator );
			if( pos != std::string::npos )
			{
				const std::string key = itor->substr( 0u, pos );
				if( !key.empty() )
				{
					const std::string value = itor->substr( pos + 1u );
					retVal[key] = value;
				}
			}
			++itor;
		}

		return retVal;
	}
	//-------------------------------------------------------------------------
	template <typename T>
	bool toUint( const std::string &value, T &outValue )
	{
		if( value.empty() )
			return false;

		char *endPtr;
		long result = strtol( &( *value.begin() ), &endPtr, 0 );

		const bool bValid = &( *value.begin() ) != endPtr && *endPtr == '\0';

		if( bValid )
			outValue = static_cast<T>( result );

		return bValid;
	}
	//-------------------------------------------------------------------------
	template <typename T>
	T toUintWithDefault( const std::string &value, T defaultValue )
	{
		T retVal;
		const bool bValid = toUint( value, retVal );
		if( !bValid )
			retVal = defaultValue;
		return retVal;
	}
	//-------------------------------------------------------------------------
	bool toU32( const std::string &value, uint32_t &outValue ) { return toUint( value, outValue ); }
	//-------------------------------------------------------------------------
	uint32_t toU32withDefault( const std::string &value, uint32_t defaultVal )
	{
		return toUintWithDefault( value, defaultVal );
	}
	//-------------------------------------------------------------------------
	bool toU16( const std::string &value, uint16_t &outValue ) { return toUint( value, outValue ); }
	//-------------------------------------------------------------------------
	uint16_t toU16withDefault( const std::string &value, uint16_t defaultVal )
	{
		return toUintWithDefault( value, defaultVal );
	}
}  // namespace sds
