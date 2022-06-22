
#ifndef RunGuard_H
#define RunGuard_H

#include <QObject>
#include <QSharedMemory>
#include <QSystemSemaphore>

/** 使用 共享内存+信号量 来控制一次启动
移动平台运行互斥管理 ：通过共享内存方式来进行程序互斥操作 **/

class RunGuard
{
public:
    RunGuard( const QString& key );
    ~RunGuard();

    bool isAnotherRunning();
    bool tryToRun();
    void release();

private:
    const QString key;

    const QString memLockKey;
	const QString sharedmemKey;

	QSystemSemaphore memLock;
    QSharedMemory sharedMem;

    Q_DISABLE_COPY( RunGuard )
};

#endif
