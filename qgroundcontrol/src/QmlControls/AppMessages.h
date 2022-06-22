
#pragma once

#include <QObject>
#include <QStringListModel>
#include <QUrl>
#include <QFile>

// Hackish way to force only this translation unit to have public ctor access
#ifndef _LOG_CTOR_ACCESS_
#define _LOG_CTOR_ACCESS_ private
#endif

class AppLogModel : public QStringListModel
{
    Q_OBJECT
public:
    Q_INVOKABLE void writeMessages(const QString dest_file);
	static void log(const QString message);

signals:
	void emitLog(const QString message);
    void writeStarted();
    void writeFinished(bool success);

private slots:
	void threadsafeLog(const QString message);

private:
    QFile _logFile;

_LOG_CTOR_ACCESS_:
    AppLogModel();
};


class AppMessages
{
public:
	static void installHandler(); // 重定向 qDebug()、qWarning()等宏的处理
    static AppLogModel* getModel();
};
