// Copyright (c) 2018-present Art of the State LLC
// Under MIT License. See LICENSE.md for details

#pragma once

#include <stdint.h>
#include <algorithm>
#include <string>
#include <cstddef>

namespace sds
{
	/** @ingroup sds
	@class fstream
		SDS stands for "super duper standard library replacement". Yes, silly name.

		fstream is a near-drop-in replacement for std::ifstream & ofstream which
		relies on C fstreams as a backend.

		The main reason for this development is to provide easier read() and write() functions
		and to provide fsync which is an important missing function from the STL.
	*/
	class fstream
	{
	public:
		enum FileOpenMode
		{
			Input,
			/// Same as Input, but starts the cursor at the end of the file
			InputEnd,
			/// File is kept, must exist
			OutputKeep,
			/// Same as OutputKeep, but starts the cursor at the end of the file
			OutputKeepEnd,
			OutputDiscard,
			/// Same as OutputKeep, but allows reading
			InOutKeep,
			/// Same as OutputEnd, but allows reading
			InOutEnd,
		};

		enum StatusBits
		{
			eof = 1u << 0u,
			badbit = 1u << 1u,
			failbit = 1u << 2u,
		};
		enum Whence
		{
			beg,
			cur,
			end,
		};

	protected:
		FILE *  m_handle;
		uint8_t m_statusBits;
		bool    m_canRead;
		bool    m_canWrite;

	public:
		fstream();
		fstream( const std::string &fullpath, FileOpenMode mode, const bool bFromBundle = true );
		fstream( const char *fullpath, FileOpenMode mode, const bool bFromBundle = true );
		~fstream();

		/**
		@brief open
		@param fullpath
		@param mode
		@param bFromBundle
			If mode contains Write operations, this value is ignored.

			When true (and mode is read-only), we assume we're reading from the app's bundle
			(e.g. on Android we're reading from the APK).
			When false, we're reading from a regular file.

			This value is only used by derived implementations like fstreamApk. The base
			implementation does not use it.
		*/
		void open( const std::string &fullpath, FileOpenMode mode, const bool bFromBundle = true );
		void open( const char *fullpath, FileOpenMode mode, const bool bFromBundle = true );
		void close();

		bool is_open() const;
		bool good();
		bool is_eof() const;

		size_t read( char *outData, size_t sizeBytes );
		size_t write( const char *inData, size_t sizeBytes );

		void   seek( ptrdiff_t dir, Whence whence );
		size_t tell();

		/** Note: Not all implementations cache this value, so don't call it
			repeatedly unnecessarily
		@param bRestoreOffset
			When true, cursor offset is left exactly where it was before calling
			When false, cursor offset is left undefined
			(i.e. you *must* call seek() afterwards)

			This is an optimization:

			@code
				sds::PackageFstream inFile( path, sds::fstream::InputEnd );
				const size_t fileSize = inFile.getFileSize( false );
				inFile.seek( 0, sds::fstream::beg );
			@endcode
		@return
			Size in bytes
			std::numeric_limits<size_t>::max() on error
		*/
		size_t getFileSize( const bool bRestoreOffset );

		int flush();

		/// Implies calling flush()
		void fsync( bool preferDataSync );

		template <typename T>
		size_t read( T &outValue )
		{
			return read( reinterpret_cast<char *>( &outValue ), sizeof( T ) );
		}
		template <typename T>
		T read()
		{
			T value = (T)0;
			read( reinterpret_cast<char *>( &value ), sizeof( T ) );
			return value;
		}
		template <typename T>
		size_t write( T inValue )
		{
			return write( reinterpret_cast<const char *>( &inValue ), sizeof( T ) );
		}

		/// Same as readString, but assumes the length is an 8-bit value
		std::string readString8()
		{
			const uint8_t strLength = read<uint8_t>();
			std::string   string;
			string.resize( strLength );

			if( strLength )
				read( reinterpret_cast<char *>( &string[0] ), strLength );

			return string;
		}

		std::string readString32()
		{
			const uint32_t strLength = read<uint32_t>();
			std::string    string;
			string.resize( strLength );

			if( strLength )
				read( reinterpret_cast<char *>( &string[0] ), strLength );

			return string;
		}

		/// Same as writeString, but assumes the length is an 8-bit value
		void writeString8( const std::string &inValue )
		{
			const uint8_t strSize = static_cast<uint8_t>( std::min<size_t>( inValue.size(), 255u ) );
			write<uint8_t>( strSize );
			write( inValue.c_str(), strSize );
		}

		void writeString32( const std::string &inValue )
		{
			const uint32_t strSize =
				static_cast<uint32_t>( std::min<size_t>( inValue.size(), 4294967295u ) );
			write<uint32_t>( strSize );
			write( inValue.c_str(), strSize );
		}
	};

	template <>
	size_t fstream::read<bool>( bool &outValue );
	template <>
	size_t fstream::write<bool>( bool inValue );
}  // namespace sds
