
#ifndef QGC_H
#define QGC_H

#include <QDateTime>
#include <QColor>
#include <QThread>

#include "QGCConfig.h"

namespace QGC
{

/* 以微秒为单位获取当前时间。这没有微秒精度，它仅限于毫秒精度。
 * @brief Get the current ground time in microseconds.
 * @note This does not have microsecond precision,
 * it is limited to millisecond precision. */
quint64 groundTimeUsecs();
/* @brief Get the current ground time in milliseconds */
quint64 groundTimeMilliseconds();
/* * @brief Get the current ground time in fractional seconds
 * @note Precision is limited to milliseconds. */
qreal groundTimeSeconds();
/* @brief Returns the angle limited to -pi - pi */
float limitAngleToPMPIf(double angle);
/* @brief Returns the angle limited to -pi - pi */
double limitAngleToPMPId(double angle);
/* @brief Records boot time (called from main) 记录启动时间 */
void initTimer();
/* @brief Get the ground time since boot in milliseconds
获取自启动以来的时间（毫秒）*/
quint64 bootTimeMilliseconds();

const static int MAX_FLIGHT_TIME = 60 * 60 * 24 * 21; /* 最大飞行时间 */
class SLEEP : public QThread
{
	Q_OBJECT
public:
	using QThread::sleep;
	using QThread::msleep;
	using QThread::usleep;
};

quint32 crc32(const quint8 *src, unsigned len, unsigned state);

}

#define QGC_EVENTLOOP_DEBUG 0

#endif // QGC_H
