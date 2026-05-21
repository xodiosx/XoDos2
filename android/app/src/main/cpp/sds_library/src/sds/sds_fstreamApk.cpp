// Copyright (c) 2018-present Art of the State LLC
// Under MIT License. See LICENSE.md for details

#ifdef __ANDROID__

#	include "sds/sds_fstreamApk.h"

#	include <android/asset_manager.h>

#	include <stdio.h>
#	include <limits>

namespace sds
{
	AAssetManager *fstreamApk::ms_assetManager = 0;
	//-------------------------------------------------------------------------
	fstreamApk::fstreamApk() : m_aAsset( 0 ), m_apkBuffer( 0 ), m_apkSize( 0u ), m_currentOffset( 0u ) {}
	//-------------------------------------------------------------------------
	fstreamApk::fstreamApk( const char *fullpath, FileOpenMode mode, const bool bFromBundle ) :
		m_aAsset( 0 ),
		m_apkBuffer( 0 ),
		m_apkSize( 0u ),
		m_currentOffset( 0u )
	{
		open( fullpath, mode, bFromBundle );
	}
	//-------------------------------------------------------------------------
	fstreamApk::fstreamApk( const std::string &fullpath, FileOpenMode mode, const bool bFromBundle ) :
		m_aAsset( 0 ),
		m_apkBuffer( 0 ),
		m_apkSize( 0u ),
		m_currentOffset( 0u )
	{
		open( fullpath.c_str(), mode, bFromBundle );
	}
	//-------------------------------------------------------------------------
	fstreamApk::~fstreamApk() { close(); }
	//-------------------------------------------------------------------------
	void fstreamApk::open( const std::string &fullpath, FileOpenMode mode, const bool bFromBundle )
	{
		open( fullpath.c_str(), mode, bFromBundle );
	}
	//-------------------------------------------------------------------------
	void fstreamApk::open( const char *fullpath, FileOpenMode mode, const bool bFromBundle )
	{
		close();

		if( !bFromBundle || mode >= OutputKeep )
		{
			// Normal file
			fstream::open( fullpath, mode, false );
			return;
		}

		m_aAsset = AAssetManager_open( ms_assetManager, fullpath, AASSET_MODE_BUFFER );

		if( m_aAsset )
		{
			m_canRead = true;

			m_apkSize = static_cast<uint64_t>( AAsset_getLength64( m_aAsset ) );
			m_apkBuffer = reinterpret_cast<const uint8_t *>( AAsset_getBuffer( m_aAsset ) );
			m_currentOffset = 0u;

			if( m_aAsset && mode == fstreamApk::InputEnd )
			{
				seek( 0, fstreamApk::end );
			}
		}
	}
	//-------------------------------------------------------------------------
	void fstreamApk::close()
	{
		if( !isBundle() )
		{
			fstream::close();
			return;
		}

		AAsset_close( m_aAsset );
		m_aAsset = 0;
		m_apkSize = 0u;
		m_apkBuffer = 0;
		m_currentOffset = 0u;

		m_statusBits = 0u;
		m_canRead = false;
		m_canWrite = false;
	}
	//-------------------------------------------------------------------------
	bool fstreamApk::is_open() const { return m_aAsset != 0 || m_handle != 0; }
	//-------------------------------------------------------------------------
	bool fstreamApk::good()
	{
		if( !isBundle() )
			return fstream::good();

		if( m_aAsset == 0 )
			return false;

		return m_statusBits == 0u || m_statusBits == fstreamApk::eof;
	}
	//-------------------------------------------------------------------------
	size_t fstreamApk::read( char *outData, size_t sizeBytes )
	{
		if( !isBundle() )
			return fstream::read( outData, sizeBytes );

		const size_t bytesToRead = std::min( sizeBytes, m_apkSize - m_currentOffset );
		memcpy( outData, m_apkBuffer + m_currentOffset, bytesToRead );
		m_currentOffset += bytesToRead;

		if( m_currentOffset >= m_apkSize )
			m_statusBits |= fstreamApk::eof;

		return bytesToRead;
	}
	//-------------------------------------------------------------------------
	void fstreamApk::seek( ptrdiff_t dir, Whence whence )
	{
		if( !isBundle() )
			return fstream::seek( dir, whence );

		if( !good() )
		{
			m_statusBits |= fstreamApk::failbit;
			return;
		}

		switch( whence )
		{
		case fstreamApk::beg:
			if( dir < 0 || static_cast<uint64_t>( dir ) > m_apkSize )
				m_statusBits |= fstreamApk::failbit;
			else
				m_currentOffset = static_cast<uint64_t>( dir );
			break;
		case fstreamApk::cur:
			if( ( dir < 0 && static_cast<uint64_t>( -dir ) > m_currentOffset ) ||
				( dir > 0 && static_cast<uint64_t>( static_cast<ptrdiff_t>( m_currentOffset ) + dir ) >
								 m_apkSize ) )
			{
				m_statusBits |= fstreamApk::failbit;
			}
			else
			{
				m_currentOffset =
					static_cast<uint64_t>( static_cast<ptrdiff_t>( m_currentOffset ) + dir );
			}
			break;
		case fstreamApk::end:
			if( dir < 0 || static_cast<uint64_t>( dir ) > m_apkSize )
				m_statusBits |= fstreamApk::failbit;
			else
				m_currentOffset = static_cast<uint64_t>( static_cast<ptrdiff_t>( m_apkSize ) - dir );
			break;
		}

		// Clear eof bit but only if there are no errors
		if( m_statusBits == StatusBits::eof && m_currentOffset < m_apkSize )
			m_statusBits = 0;
	}
	//-------------------------------------------------------------------------
	size_t fstreamApk::tell()
	{
		if( !isBundle() )
			return fstream::tell();

		if( !good() )
		{
			m_statusBits |= fstreamApk::failbit;
			return std::numeric_limits<size_t>::max();
		}

		return static_cast<size_t>( m_currentOffset );
	}
	//-------------------------------------------------------------------------
	size_t fstreamApk::getFileSize( const bool bRestoreOffset )
	{
		if( !isBundle() )
			return fstream::getFileSize( bRestoreOffset );

		if( !good() )
		{
			m_statusBits |= fstreamApk::failbit;
			return std::numeric_limits<size_t>::max();
		}

		return static_cast<size_t>( AAsset_getLength64( m_aAsset ) );
	}
	//-------------------------------------------------------------------------
	template <>
	size_t fstreamApk::read<bool>( bool &outValue )
	{
		uint8_t value = 0;
		const size_t retVal = read<uint8_t>( value );
		outValue = value != 0;
		return retVal;
	}
}  // namespace sds
#endif
