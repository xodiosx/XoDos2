// Copyright (c) 2018-present Art of the State LLC
// Under MIT License. See LICENSE.md for details

#pragma once

#include <limits>
#include <string>

#if defined( __has_builtin )
#	define SDS_HAS_BUILTIN( x ) __has_builtin( x )
#else
#	define SDS_HAS_BUILTIN( x ) 0
#endif

namespace sds
{
	/// Returns true if s1 > s2, checks for wrap-around.
	template <typename T>
	static bool isSequenceMoreRecent( T s1, T s2 )
	{
		// clang-format off
		const T max = std::numeric_limits<T>::max();
		return
			( ( s1 > s2 ) &&
			  ( s1 - s2 <= (max >> 1u) ) )
			   ||
			( ( s2 > s1 ) &&
			  ( s2 - s1  > (max >> 1u) ) );
		// clang-format on
	}

	/// Performs the same as std::bit_cast
	/// i.e. the same as reinterpret_cast but without breaking strict aliasing rules
	template <class Dest, class Source>
#if SDS_HAS_BUILTIN( __builtin_bit_cast ) || _MSC_VER >= 1928
	constexpr
#else
	inline
#endif
		Dest
		bit_cast( const Source &source )
	{
#if SDS_HAS_BUILTIN( __builtin_bit_cast ) || _MSC_VER >= 1928
		return __builtin_bit_cast( Dest, source );
#else
		static_assert( sizeof( Dest ) == sizeof( Source ),
					   "bit_cast requires source and destination to be the same size" );
		static_assert( std::is_trivially_copyable<Dest>::value,
					   "bit_cast requires the destination type to be copyable" );
		static_assert( std::is_trivially_copyable<Source>::value,
					   "bit_cast requires the source type to be copyable" );
		Dest dest;
		memcpy( &dest, &source, sizeof( dest ) );
		return dest;
#endif
	}
}  // namespace sds
