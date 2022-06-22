/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#include "QDebug"

#include "RunGuard.h"
#include <QCryptographicHash>

namespace
{

QString generateKeyHash( const QString& key, const QString& salt )
{
	QByteArray data;

	data.append( key.toUtf8() );
	data.append( salt.toUtf8() );
	data = QCryptographicHash::hash( data, QCryptographicHash::Sha1 ).toHex();

	zcq_debug_echo(__FILE__, __func__, __LINE__, "data=" << data)
			return data;
}

}

RunGuard::RunGuard( const QString& key )
	: key( key )
	, memLockKey( generateKeyHash( key, "_memLockKey" ) )
	, sharedmemKey( generateKeyHash( key, "_sharedmemKey" ) )
	, memLock( memLockKey, 1 )
	, sharedMem( sharedmemKey )
{
	memLock.acquire();
	{
		QSharedMemory fix( sharedmemKey );
		// Fix for *nix: http://habrahabr.ru/post/173281/
		fix.attach();
	}
	memLock.release();
}

RunGuard::~RunGuard()
{
	release();
}

bool RunGuard::isAnotherRunning()
{
	if ( sharedMem.isAttached() )
		return false;

	memLock.acquire();
	const bool isRunning = sharedMem.attach();
	if ( isRunning ) sharedMem.detach();
	memLock.release();

	return isRunning;
}

bool RunGuard::tryToRun()
{
	if ( isAnotherRunning() )   // Extra check
		return false;

	memLock.acquire();
	/* 创建共享内存，向os申请内存空间，如果不创建，调用 attach(）会失败 */
	const bool result = sharedMem.create( sizeof( quint64 ) );
	memLock.release();
	if ( !result )
	{
		release();
		return false; // run error
	}

	return true; // run ok
}

void RunGuard::release()
{
	memLock.acquire();
	if ( sharedMem.isAttached() ) sharedMem.detach();
	memLock.release();
}
