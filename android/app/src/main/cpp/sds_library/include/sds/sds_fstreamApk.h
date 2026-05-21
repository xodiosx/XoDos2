// Copyright (c) 2018-present Art of the State LLC
// Under MIT License. See LICENSE.md for details

#pragma once

#include "sds_fstream.h"
#include <cstddef>

struct AAsset;
typedef struct AAssetManager AAssetManager;

namespace sds
{
	/** @ingroup sds
	@class fstreamApk
		fstreamApk is like fstream but actually reads from APK when requested

	@remarks
		ms_assetManager MUST be set externally before using any function

		We're not using virtual functions. Casting fstreamApk to fstream will produce errors
		if using the read functions of an APK.
	*/
	class fstreamApk : protected fstream
	{
	protected:
		AAsset *       m_aAsset;
		uint8_t const *m_apkBuffer;
		uint64_t       m_apkSize;
		uint64_t       m_currentOffset;

	public:
		fstreamApk();
		fstreamApk( const std::string &fullpath, FileOpenMode mode, const bool bFromBundle = true );
		fstreamApk( const char *fullpath, FileOpenMode mode, const bool bFromBundle = true );
		~fstreamApk();

		static AAssetManager *ms_assetManager;

		/**
		@brief open
		@param fullpath
		@param mode
		@param bFromBundle
			If mode contains Write operations, this value is ignored.

			When true (and mode is read-only), we assume we're reading from the app's bundle
			(e.g. on Android we're reading from the APK).
			When false, we're reading from a regular file.

			This value is only used by derived implementations like fstreamApkApk. The base
			implementation does not use it.
		*/
		void open( const std::string &fullpath, FileOpenMode mode, const bool bFromBundle = true );
		void open( const char *fullpath, FileOpenMode mode, const bool bFromBundle = true );
		void close();

		bool is_open() const;
		bool good();
		using fstream::is_eof;

		using fstream::read;
		size_t read( char *outData, size_t sizeBytes );

		void   seek( ptrdiff_t dir, Whence whence );
		size_t tell();

		size_t getFileSize( const bool bRestoreOffset );

		using fstream::flush;
		using fstream::fsync;
		using fstream::write;

		bool isBundle() const { return m_aAsset != 0; }

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
	};

	template <>
	size_t fstream::read<bool>( bool &outValue );
}  // namespace sds
